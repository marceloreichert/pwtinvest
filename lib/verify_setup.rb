module VerifySetup
  extend self

  def verify( ticks,
              indice,
              setup,
              id_do_padrao,
              data_do_padrao,
              valor_perda_trade,
              valor_perda_geral,
              pe1_ponto_de_entrada,
              pe1_valor,
              pe1_acima_abaixo,
              pe1_ponto_do_candle,
              pe1_qual_candle,
              pstop1,
              pstop2,
              pstop3,
              pstop4,
              ps1,
              ponto_zerar_risco_percentual,
              quantidade_maxima_de_candles_do_trade )

    ret = find(ticks, indice, setup[:id], quantidade_maxima_de_candles_do_trade)

    return nil if not ret[:find]
    return nil if not validate_relation(ret[:candles_on_setup], setup[:id])

    quantidade_candles_do_padrao = ret[:candles_on_setup].length
    valor_ponto_de_entrada = Backtest.identifica_valor_ponto_de_entrada(pe1_valor, pe1_acima_abaixo, pe1_ponto_do_candle, pe1_qual_candle, ret[:candles_on_setup])
    valor_ponto_de_stop = Backtest.identifica_valor_ponto_de_stop(pstop1, pstop2, pstop3, pstop4, ret[:candles_on_setup])
    valor_ponto_de_saida = Backtest.identifica_valor_ponto_de_saida(valor_ponto_de_entrada, ps1)
    dados_do_proximo_candle_apos_padrao = Backtest.identifica_dados_do_proximo_candle_apos_padrao(ret[:candles_after_setup], pe1_ponto_de_entrada, quantidade_candles_do_padrao)

    return {    :id => id_do_padrao,
                :status => "ENCONTRADO",
                :numero_trades => 1,
                :lotes_comprados => 0,
                :lotes_a_vender => 0,
                :lote_zerar_risco => 0,
                :perc_a_vender => 100,
                :data_do_padrao => data_do_padrao,
                :data_da_compra => dados_do_proximo_candle_apos_padrao[:data_da_compra],
                :valor_para_validar_padrao => dados_do_proximo_candle_apos_padrao[:valor_para_validar_padrao],
                :valor_ponto_compra => valor_ponto_de_entrada,
                :valor_ponto_stop => valor_ponto_de_stop,
                :valor_ponto_venda => valor_ponto_de_saida,
                :valor_ponto_zerar_risco => 0,
                :valor_total_compra => 0,
                :valor_total_venda => 0,
                :valor_total_em_aberto => 0,
                :valor_media => 0,
                :valor_cruzamento_media_1 => 0,
                :valor_cruzamento_media_2 => 0,
                :valor_ifr => 0,
                :tipo_validacao => dados_do_proximo_candle_apos_padrao[:tipo_validacao],
                :historico => [],
                :candles_do_padrao => ret[:candles_on_setup],
                :candles_apos_padrao => ret[:candles_after_setup],
                :risco_do_trade => 0  }
  end

  def find(tick, idx, setup_id, max_candles_after_trade)

    setup = Setup.busca_setup(setup_id)
    candles_on_setup = []
    candles_after_setup = []
    find = true

    setup_quantity_candle = setup[:quantity_candle].to_i

    (1..setup_quantity_candle).each  do |candle|

      case candle
      when 1
        setup_candle_status = setup[:first_candle]
        setup_candle_type = setup[:first_candle_type]
      when 2
        setup_candle_status = setup[:second_candle]
        setup_candle_type = setup[:second_candle_type]
      when 3
        setup_candle_status = setup[:third_candle]
        setup_candle_type = setup[:third_candle_type]
      end

      setup_candle_type = "" if setup_candle_type.nil?

      t = tick.at(idx + (candle - 1))

      if t.nil?
        find = false
        break
      end

      #Verifica o tipo de cada candle A=Alta, B=Baixa ou "N"=Sei la
      if t.type_candle == setup_candle_status || setup_candle_status == "N"

        find = true
        candles_on_setup  <<  { :date_quotation => t.date_quotation,
                                :open => t.open,
                                :close => t.close,
                                :low => t.low,
                                :high => t.high }
      else
        find = false
        break
      end

      #Verifica se candle eh MARTELO
      if setup_candle_type.downcase == 'martelo'

        if t.type_candle == "A"
          valor_sombra_inferior = t.open - t.low
          valor_sombra_superior = t.high - t.close
        else
          valor_sombra_inferior = t.close - t.low
          valor_sombra_superior = t.high - t.open
        end

        valor_corpo = t.open - t.close
        valor_corpo = valor_corpo.abs

        if valor_sombra_inferior > (valor_corpo * 2) && valor_sombra_superior < valor_corpo
          find = true
        else
          find = false
          break
        end
      end
    end

    ## find candles after setup
    if find
      pos_inicial = candles_on_setup.length + 1
      pos_final = pos_inicial + (max_candles_after_trade.to_i - 1)

      (pos_inicial..pos_final).each  do |position_candle|
        t = tick.at(idx + (position_candle - 1))

        break if t.nil?

        candles_after_setup << {:date_quotation => t.date_quotation,
                                :open => t.open,
                                :close => t.close,
                                :low => t.low,
                                :high => t.high }
       end
    end

    if candles_after_setup.size  ==  0
      find = false
      candles_on_setup = []
      candles_after_setup = []
    end

    return  { :find => find,
              :candles_on_setup => candles_on_setup,
              :candles_after_setup => candles_after_setup }
  end

  def validate_relation(candles_do_padrao, setup_id)

    setup_rels = relation_list(setup_id)
    valido = true

    setup_rels.each do |rel|
      if valido
        if rel.candle_x_position == 'primeiro'
          candle_x_position = 1
        elsif rel.candle_x_position == 'segundo'
          candle_x_position = 2
        elsif rel.candle_x_position == 'terceiro'
          candle_x_position = 3
        end

        cot = candles_do_padrao[(candle_x_position - 1 )]

        if rel.candle_x_value == 'abertura'
          candle_x_value = cot[:open]
        elsif rel.candle_x_value == 'fechamento'
          candle_x_value = cot[:close]
        elsif rel.candle_x_value == 'maxima'
          candle_x_value = cot[:high]
        elsif rel.candle_x_value == 'minima'
          candle_x_value = cot[:low]
        end


        if rel.candle_y_position == 'primeiro'
          candle_y_position = 1
        elsif rel.candle_y_position == 'segundo'
          candle_y_position = 2
        elsif rel.candle_y_position == 'terceiro'
          candle_y_position = 3
        end

        cot = candles_do_padrao[(candle_y_position - 1 )]

        if rel.candle_y_value == 'abertura'
          candle_y_value = cot[:open]
        elsif rel.candle_y_value == 'fechamento'
          candle_y_value = cot[:close]
        elsif rel.candle_y_value == 'maxima'
          candle_y_value = cot[:high]
        elsif rel.candle_y_value == 'minima'
          candle_y_value = cot[:low]
        end



        if rel.value == 'maior'
          if candle_x_value > candle_y_value
            valido = true
          else
            valido = false
          end
        end

        if rel.value == 'menor'
          if candle_x_value < candle_y_value
            valido = true
          else
            valido = false
          end
        end
      end
    end
    return valido
  end

  def relation_list(setup_id)
    return SetupRel.where('setup_id = ?', setup_id)
  end

end
