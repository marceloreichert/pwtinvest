include ActionView::Helpers::NumberHelper

class Validate

  ###########################
  # => candles for setup
  #
  # => setup_found = [[0,1], [3,4]]
  #
  # => index to localize candles
  #
  # => i1   ao_atingir
  #         ao_fechar
  #
  # => i2   values (0,01)
  #
  # => i3   <acima>
  #         <abaixo>
  #
  # => i4   high
  #         low
  #         open
  #         close
  #
  # => i5   first candle
  #         second candle
  #         third candle
  ###########################
  def self.validate(ticks, setup_found, i1, i2, i3, i4, i5 )

    setup_validado  = []

    setup_found.each  do |setup_index|

      candle = candle_i5(ticks, setup_index, i5.to_i)

      value_for_validate = point_for_validate(i2, i3, i4, candle )

      candle_after_setup = ticks.at( setup_index.size)

      i1 == "ao_atingir" ? value = candle_after_setup[:high] : value = candle_after_setup[:close]

      status = nil

      if value_for_validate == 0
        status = "NAO VALIDADO"
        historico = "Nao encontrado valor para validar candle."
      end

      ###########################
      # Padrao NAO validado. Candle após padrao nao ultrapassou valor de compra do padrao.
      if status.nil? && value <= value_for_validate
        status = "NAO VALIDADO"
        historico = "O candle do dia "
        historico << candle_after_setup[:date_quotation].strftime("%d/%m/%Y")
        historico << " nao "
        historico << i1 + " ponto de entrada em "
        historico << number_to_currency(value_for_validate) << ". "
      else
        status = "VALIDADO"
        historico = ""
      end
binding.pry
      #--Valor a ser comprado, mais o valor de compras em aberto nao pode ser maior
      #--que o valor maximo cadastrado de perda (6% ou R$6.000,00 => base R$100.000,00)
      if perda_geral_enabled && status.nil?
        if @risco_acumulado + risco_do_trade > valor_perda_geral
          status = "VALIDADO/NAO COMPRADO"
          historico = "Risco geral ultrapassou o maximo permitido de " + number_to_currency(valor_perda_geral) + "."
        else
          lotes_comprados = (valor_perda_geral.to_f + valor_corretagem.to_f) / (value_for_validate - trade[:valor_ponto_stop].to_f)
          lotes_comprados = lotes_comprados / nr_lote_minimo
          lotes_comprados = nr_lote_minimo * lotes_comprados

          valor_total_compra = value_for_validate * lotes_comprados
          valor_total_compra = valor_total_compra + valor_corretagem.to_f

          risco_do_trade = valor_total_compra - (lotes_comprados * trade[:valor_ponto_stop].to_f)

          if lotes_comprados <= 0
            status = "VALIDADO/NAO COMPRADO"
            historico = "O percentual de " + perc_perda_maxima.to_s + "% ("+ perda_geral.to_s + ") de risco maximo geral foi atingido. "
          end
        end
      end

      #--Valor a ser comprado nao pode ser maior que saldo da c/c
      if status.nil?
        if valor_total_compra > @saldo
          lotes_comprados = (@saldo - valor_corretagem.to_f) / trade[:valor_ponto_compra]
          lotes_comprados = lotes_comprados / nr_lote_minimo
          lotes_comprados = nr_lote_minimo * lotes_comprados.to_i

          valor_total_compra = trade[:valor_ponto_compra] * lotes_comprados
          valor_total_compra = valor_total_compra + valor_corretagem.to_f

          risco_do_trade = valor_total_compra - (lotes_comprados * trade[:valor_ponto_stop].to_f)

          if lotes_comprados <= 0
            valor_lote_minimo = trade[:valor_ponto_compra] * nr_lote_minimo

            status = "VALIDADO/NAO COMPRADO"
            historico = "Nao existe saldo suficiente para comprar lote. Saldo atual e de " + number_to_currency(@saldo)
            historico << " e valor do lote minimo e de " + number_to_currency(valor_lote_minimo) + "."
          end
        end
      end

      if status.nil? && mm_enabled
        retorno = Backtest.valida_media_movel(trade[:candles_do_padrao], setup, mm_enabled, mm_local)
        if not retorno[:encontrei]
          status = "VALIDADO/NAO COMPRADO"
          historico = retorno[:historico]
        end
      end

      if status.nil?
        valor_venda_alijar_risco = 0
        perc_a_vender = 100

        if ponto_zerar_risco_percentual.to_i < 100
          lote_zerar_risco = lotes_comprados.to_f * (ponto_zerar_risco_percentual.to_f / 100.0)
          lote_zerar_risco = lote_zerar_risco.to_i
          lote_restante = lotes_comprados.to_i - lote_zerar_risco
          valor_venda_restante = lote_restante * trade[:valor_ponto_stop]
          valor_venda_alijar_risco = (valor_total_compra - valor_venda_restante) / lote_zerar_risco.to_f
        end

        if lotes_comprados > 0
          @saldo = @saldo - valor_total_compra.to_f
          @risco_acumulado = @risco_acumulado + risco_do_trade
          perc_risco_acumulado = (@risco_acumulado * 100) / @vlr_investiment

          status = "VALIDADO"
          historico = "Candle do dia "
          historico << trade[:data_da_compra].strftime("%d/%m/%Y") << " "
          historico << trade[:tipo_validacao] + " em " + number_to_currency(trade[:valor_ponto_compra]) + ". "
          historico << "Comprados " + lotes_comprados.to_s + " lotes "
          historico << "com investimentos de " << number_to_currency(valor_total_compra) << ". "
          historico << "Risco do trade de " + number_to_currency(risco_do_trade) << "."

          trade[:risco_do_trade] = risco_do_trade

          @list << insert_list( trade[:data_da_compra], valor_total_compra, "C", trade[:id], @saldo, risco_do_trade, @risco_acumulado)
        else
          status = "NAO VALIDADO"
          historico = "Valor de lotes comprados invalido."
        end
      end


      setup_validado << {setup: setup_index, status: status, historico: historico}
    end
    setup_validado
  end

  ###########################
  # => candles for setup
  #
  # => setup_found_index [[0,1], [3,4]]
  #
  # => i5   first candle
  #         second candle
  #         third candle
  ###########################
  def self.candle_i5(ticks, setup_found_index, i5)
    ticks.at(setup_found_index[i5 - 1])
  end

  ################################################################
  # => i2   values (0,01)
  #
  # => i3   <acima>
  #         <abaixo>
  #
  # => i4   high
  #         low
  #         open
  #         close
  #
  # => candle_i5  firts/second/third candle of setup
  ################################################################
  def self.point_for_validate(i2, i3, i4, candle_i5 )
    return nil if i2 == 0

    p = [['da maxima','high'], ['da minima','low'], ['da abertura','open'], ['do fechamento','close']]
    if  p[0][1]  !=  i4 &&
        p[1][1]  !=  i4 &&
        p[2][1]  !=  i4 &&
        p[3][1]  !=  i4
      return nil
    end

    if i4 == "high"
      value_candle_i5 = candle_i5[:high]
    elsif i4 == "low"
      value_candle_i5 = candle_i5[:low]
    elsif i4 == "open"
      value_candle_i5 = candle_i5[:open]
    elsif i4 == "close"
      value_candle_i5 = candle_i5[:close]
    else
      return nil
    end

    #pe3 => "acima", "abaixo"
    value = 0
    if i3 == "acima"
      value = i2.to_f
    elsif i3 == "abaixo"
      value = i2.to_f * (-1)
    end

    value_candle_i5 = value_candle_i5 + value
  end


  def self.valida_padrao( trade,
                          data,
                          ponto_zerar_risco_percentual,
                          valor_perda_trade,
                          valor_perda_geral,
                          valor_corretagem,
                          setup,
                          perc_perda_geral,
                          perda_geral_enabled,
                          paper
                        )

    lotes_comprados = 0
    lote_zerar_risco = 0
    valor_venda_alijar_risco = 0
    valor_total_compra = 0
    historico = nil
    status = nil

    nr_lote_minimo = Paper.busca_papel(paper[:id]).nr_lote

    nr_lote_minimo = 1 if paper.nil?


    retorno = { :status => status,
                :lotes_comprados => lotes_comprados,
                :lotes_para_zerar_risco => lote_zerar_risco,
                :valor_ponto_zerar_risco => valor_venda_alijar_risco,
                :valor_total_compra => valor_total_compra,
                :historico => {:title => status, :description => historico } }

    return  retorno
  end

end