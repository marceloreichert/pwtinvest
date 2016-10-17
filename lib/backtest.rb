module Backtest
  include ActionView::Helpers::NumberHelper
  extend self

  def backtest  (     cotacoes,
                      dt_inicial,
                      dt_final,
                      paper,
                      setup,

                      pe1_ponto_de_entrada,
                      pe1_valor,
                      pe1_acima_abaixo,
                      pe1_ponto_do_candle,
                      pe1_qual_candle,

                      ponto_stop_valor,
                      ponto_stop_acima_abaixo,
                      ponto_stop_ponto_do_candle,
                      ponto_stop_lista_de_candles,
                      quantidade_maxima_candle_trade,
                      ponto_saida_valor,
                      perc_perda_trade,
                      perc_perda_geral,
                      valor_investimento,
                      ponto_zerar_risco_percentual,
                      prazo,
                      valor_corretagem,
                      mm_enabled,
                      mm_periodos,
                      mm_local,
                      mm_tipo,
                      ifr_enabled,
                      ifr_local,
                      ifr_periodos,
                      ifr_valor,
                      perda_geral_enabled
                      )

    @cotacoes = cotacoes

    if mm_enabled
      if mm_tipo.downcase == "simples"
        calcula_media_movel_simples(@cotacoes, mm_periodos.to_i, 1)
      elsif mm_tipo.downcase == "exponencial"
        calcula_media_movel_exponencial(@cotacoes, mm_periodos.to_i, 1)
      end
    end

    if ifr_enabled
      self.calcula_ifr(@cotacoes, ifr_periodos.to_i)
    end

    @resumo_por_trade = []
    @valor_investimento = valor_investimento.to_f
    @saldo = valor_investimento.to_f
    @risco_acumulado = 0
    valor_perda_trade = @saldo * (perc_perda_trade.to_f / 100) # 100.000,00 * 2% = 2.000,00
    valor_perda_geral = @saldo * (perc_perda_geral.to_f / 100) # 100.000,00 * 6% = 6.000,00

    @extrato  = []
    @extrato << Backtest.insere_lancamentos_no_extrato(nil, 0.00, "I", nil, @saldo, 0.00, 0.00)

    indice = 0

    @cotacoes.each do |cot|

      verifica_padrao(@cotacoes,
                      indice,
                      setup,
                      cot.id,
                      cot.date_quotation,
                      valor_perda_trade,
                      valor_perda_geral,
                      pe1_ponto_de_entrada,
                      pe1_valor,
                      pe1_acima_abaixo,
                      pe1_ponto_do_candle,
                      pe1_qual_candle,
                      ponto_stop_valor,
                      ponto_stop_acima_abaixo,
                      ponto_stop_ponto_do_candle,
                      ponto_stop_lista_de_candles,
                      ponto_saida_valor,
                      ponto_zerar_risco_percentual,
                      quantidade_maxima_candle_trade
                      )

      @resumo_por_trade.each do |t|

        if t[:status] == "ENCONTRADO"
          retorno = valida_padrao(t,
                                  cot.date_quotation,
                                  ponto_zerar_risco_percentual,
                                  valor_perda_trade,
                                  valor_perda_geral,
                                  valor_corretagem,
                                  setup,
                                  ifr_enabled,
                                  ifr_local,
                                  ifr_valor,
                                  mm_enabled,
                                  mm_local,
                                  perc_perda_geral,
                                  perda_geral_enabled,
                                  paper )

          if retorno[:status] != nil
            t[:valor_ponto_zerar_risco] = retorno[:valor_ponto_zerar_risco]
            t[:lotes_comprados] = retorno[:lotes_comprados]
            t[:lotes_a_vender] = retorno[:lotes_comprados]
            t[:lote_zerar_risco] = retorno[:lotes_para_zerar_risco]
            t[:valor_total_compra] = retorno[:valor_total_compra]
            t[:valor_resultado] = 0.00
            t[:perc_resultado] = 0.00
            t[:valor_total_em_aberto] = retorno[:valor_total_compra]
            t[:status] = retorno[:status]
            t[:historico] << retorno[:historico]
          end
        end

        if t[:status] == "VALIDADO"

          if t[:numero_trades] < quantidade_maxima_candle_trade.to_i

            #Verifica se foi ESTOPADO
            if cot.low < t[:valor_ponto_stop]

              valor_total_venda = t[:valor_ponto_stop] * t[:lotes_a_vender]
              valor_total_venda = valor_total_venda - valor_corretagem.to_f

              @saldo = @saldo + valor_total_venda

              if t[:lotes_a_vender] == t[:lotes_comprados]
                @risco_acumulado = @risco_acumulado - t[:risco_do_trade]
              end

              t[:status] = "ESTOPADO"
              t[:valor_total_em_aberto] = t[:valor_total_em_aberto] - valor_total_venda
              t[:valor_total_venda] = t[:valor_total_venda] + valor_total_venda

              @extrato << Backtest.insere_lancamentos_no_extrato(cot.date_quotation, valor_total_venda, "V", t[:id], @saldo, t[:risco_do_trade], @risco_acumulado)

              historico = "Candle do dia "
              historico << cot.date_quotation.strftime("%d/%m/%Y")
              historico << " atingiu o Ponto de Stop Loss em "
              historico << number_to_currency(t[:valor_ponto_stop]) + ". "
              historico << "Vendidos " + t[:lotes_a_vender].to_s + " lotes com retorno de "
              historico << number_to_currency(valor_total_venda)
              t[:historico] << {:title => "ESTOPADO", :description => historico }
              t[:lotes_a_vender] = 0
            end

            #Verifica VENDA para ZERAR RISCO
            if t[:valor_ponto_zerar_risco] > 0 && t[:lotes_a_vender] > 0
              if cot.high >= t[:valor_ponto_zerar_risco]

                lote_zerar_risco = lote_zerar_risco.to_i
                t[:lotes_a_vender] = t[:lotes_a_vender] - t[:lote_zerar_risco]
                t[:perc_a_vender] = 100 - ponto_zerar_risco_percentual.to_i

                valor_total_venda = t[:valor_ponto_zerar_risco] * t[:lote_zerar_risco]
                valor_total_venda = valor_total_venda - valor_corretagem.to_f

                @saldo = @saldo + valor_total_venda

                risco_do_trade = t[:risco_do_trade]
                @risco_acumulado = @risco_acumulado - risco_do_trade

                t[:valor_total_em_aberto] = t[:valor_total_em_aberto] - valor_total_venda
                t[:valor_total_venda] = t[:valor_total_venda] + valor_total_venda

                @extrato << Backtest.insere_lancamentos_no_extrato(cot.date_quotation, valor_total_venda, "V", t[:id], @saldo, risco_do_trade, @risco_acumulado)

                historico = "Candle do dia " + cot.date_quotation.strftime("%d/%m/%Y")
                historico << " atingiu o Ponto de Zerar Risco em "
                historico << number_to_currency(t[:valor_ponto_zerar_risco]) + ". "
                historico << "Vendidos " + number_to_currency(t[:lote_zerar_risco]) + " lotes com retorno de "
                historico << number_to_currency(valor_total_venda)
                historico << "."
                t[:historico] << {:title => "VENDA de " + ponto_zerar_risco_percentual + "% para Zerar Risco", :description => historico }
                t[:valor_ponto_zerar_risco] = 0
              end
            end

            #Verifica se foi VENDIDO
            if cot.high >= t[:valor_ponto_venda]

              valor_total_venda = t[:valor_ponto_venda] * t[:lotes_a_vender]
              valor_total_venda = valor_total_venda - valor_corretagem.to_f
              @saldo = @saldo + valor_total_venda

              t[:valor_total_em_aberto] = t[:valor_total_em_aberto] - valor_total_venda
              t[:valor_total_venda] = t[:valor_total_venda] + valor_total_venda

              if t[:perc_a_vender].to_i < 100
                historico1 = "VENDA de " + t[:perc_a_vender].to_s + "% restante"
              else
                risco_do_trade = t[:risco_do_trade]
                @risco_acumulado = @risco_acumulado - risco_do_trade

                historico1 = "VENDA "
              end

              @extrato << Backtest.insere_lancamentos_no_extrato(cot.date_quotation, valor_total_venda, "V", t[:id], @saldo, risco_do_trade, @risco_acumulado)

              historico = "Candle do dia " + cot.date_quotation.strftime("%d/%m/%Y")
              historico << " atingiu o Ponto de Saida em "
              historico << t[:valor_ponto_venda].to_s + ". "
              historico << "Vendidos " + t[:lotes_a_vender].to_s + " lotes com retorno de "
              historico << valor_total_venda.to_s + "."
              t[:historico] << {:title => historico1, :description => historico }
              t[:lotes_a_vender] = 0
              t[:status] = "VENDIDO"
            end

            t[:numero_trades] = t[:numero_trades] + 1

          else

            if t[:status] == "VALIDADO"
              valor_saida = cot.close * t[:lotes_a_vender]
              valor_saida = valor_saida - valor_corretagem.to_f

              @saldo = @saldo + valor_saida

              t[:valor_total_em_aberto] = t[:valor_total_em_aberto] - valor_saida
              t[:valor_total_venda] = t[:valor_total_venda] + valor_saida

              if t[:perc_a_vender].to_f < 100.0
                historico1 = "VENDA de " + t[:perc_a_vender].to_s + "% restante "
              else
                historico1 = "VENDA "
                risco_do_trade = t[:risco_do_trade]
                @risco_acumulado = @risco_acumulado - risco_do_trade
              end

              @extrato << Backtest.insere_lancamentos_no_extrato(cot.date_quotation, valor_saida, "V", t[:id], @saldo, risco_do_trade, @risco_acumulado)

              historico = "Ponto de Saida ou Stop Loss nao atingidos. "
              historico << "Vendidos " + t[:lotes_a_vender].to_s + " lotes "
              historico << "no fechamento do ultimo candle do trade, "
              historico << "no dia "
              historico << cot.date_quotation.strftime("%d/%m/%Y")
              historico << ", por "
              historico << cot.close.to_s
              historico << " com retorno de "
              historico << valor_saida.to_s
              t[:historico] << {:title => historico1, :description => historico }
              t[:status] = "VENDIDO"
              t[:lotes_a_vender] = 0
            end
          end
          t[:valor_resultado] = t[:valor_total_venda] - t[:valor_total_compra]
          t[:perc_resultado] = (t[:valor_resultado].to_f * 100.00) / t[:valor_total_compra].to_f
        end
      end
      indice = indice + 1
    end

#    Rails.logger.info(@resumo_por_trade[0])

    @extrato  = Backtest.atualiza_nr_lancamento_no_extrato(@extrato)
    @totais = calcula_totais()

    retorno = { :trade => @resumo_por_trade,
                :extrato => @extrato,
                :totais => @totais }

    return  retorno
  end


  def insere_lancamentos_no_extrato(data, valor, tipo, id, saldo, risco_do_trade, risco_acumulado)

    lancamento = {:lancamento => 0,
                  :data => data,
                  :valor => valor,
                  :tipo => tipo,
                  :id => id,
                  :saldo => saldo,
                  :risco_do_trade => risco_do_trade,
                  :risco_acumulado => risco_acumulado }
  end

  def atualiza_nr_lancamento_no_extrato(extrato)
    if extrato.count > 0
      for i in 1..extrato.count
        extrato[i-1][:lancamento] = i
      end
    end
    extrato
  end

  def gera_xml_do_grafico(dados, label, quantidade_candles)
    valor_minima = 9999999
    valor_maxima = 0
    data = nil
    xInd = 1

    if quantidade_candles.nil?
      quantidade_candles = 100
    end

    dados_dos_candles_do_padrao = dados[:candles_do_padrao][0]

    dados[:candles_do_padrao].each  do |candle|
      valor_maxima = candle[:high] if valor_maxima < candle[:high]
      valor_minima = candle[:low] if valor_minima > candle[:low]
		end
    dados[:candles_apos_padrao].each  do |candle|
      valor_maxima = candle[:high] if valor_maxima < candle[:high]
      valor_minima = candle[:low] if valor_minima > candle[:low]
		end
    valor_maxima = valor_maxima + 0.5
    valor_minima = valor_minima - 0.5

    str_xml = Nokogiri::XML::Builder.new do |xml|
		  xml.graph(:caption => label,
                :yaXisMinValue => valor_minima.to_s,
                :yaXisMaxValue => valor_maxima.to_s,
								:canvasBorderColor => 'DAE1E8',
								:canvasBgColor => 'FFFFFF' ,
								:bgColor => 'EEF2FB' ,
								:numDivLines => '3' ,
								:divLineColor => 'DAE1E8' ,
								:decimalPrecision => '2' ,
								:numberPrefix => 'R$' ,
								:showNames => '1' ,
								:bearBorderColor => 'E33C3C',
								:bearFillColor => 'E33C3C' ,
								:bullBorderColor => '1F3165',
								:baseFontColor => '444C60' ,
								:outCnvBaseFontColor => '444C60',
								:hoverCapBorderColor => 'DAE1E8' ,
								:hoverCapBgColor => 'FFFFFF',
								:rotateNames => '1') do

  			xml.categories(	:font => '',
  											:fontSize => '10',
  											:fontColor => '',
  											:verticalLineColor => '',
  											:verticalLineThickness => '1',
  											:verticalLineAlpha => '100') do

          xindex = 0
          dados[:candles_do_padrao].each  do |candle|
            xindex = xindex + 1
            data = candle[:date_quotation].day.to_s << '/' << candle[:date_quotation].month.to_s
  					xml.category(	:name => data, :xIndex => xindex.to_s, :showLine => '1')
          end

          dados[:candles_apos_padrao].each  do |candle|
            xindex = xindex + 1
            data = candle[:date_quotation].day.to_s << '/' << candle[:date_quotation].month.to_s
  					xml.category(	:name => data, :xIndex => xindex.to_s, :showLine => '1')
          end
				end

				xml.data do
#            xml.set(:open => '24.6', :high => '25.24', :low => '24.58', :close => '25.19')
          dados[:candles_do_padrao].each  do |candle|
						xml.set(:open => candle[:open].to_s,
						        :high => candle[:high].to_s,
						        :low => candle[:low].to_s,
						        :close => candle[:close].to_s)
          end
          quantidade = 1
          dados[:candles_apos_padrao].each  do |candle|
          	if quantidade <= quantidade_candles
          		xml.set(:open => candle[:open].to_s,
          		        :high => candle[:high].to_s,
          		        :low => candle[:low].to_s,
          		        :close => candle[:close].to_s)
          		quantidade = quantidade + 1
	          end
				  end
			  end
			end
		end
		return str_xml
  end

  def calcula_media_movel_simples(cotacoes, periodos, tipo)

    indice = 0
    valor_total = 0

    cotacoes.each do |cotacao|

      if tipo == 1
        if cotacao[:valor_media].nil?
         cotacao[:valor_media] = 0
        end
      elsif tipo == 2
        if cotacao[:valor_cruzamento_media_1].nil?
         cotacao[:valor_cruzamento_media_1] = 0
        end
      elsif tipo == 3
        if cotacao[:valor_cruzamento_media_2].nil?
         cotacao[:valor_cruzamento_media_2] = 0
        end
      end

      (1..periodos).each do |periodo|

        cot = cotacoes.at(indice + (periodo - 1))

        if not cot.nil?
          valor_total = valor_total + cot[:valor_fechamento]

          if periodo == periodos
            valor_media = valor_total / periodos

            if tipo == 1
              cot[:valor_media] = valor_media
            elsif tipo == 2
              cot[:valor_cruzamento_media_1] = valor_media
            elsif tipo == 3
              cot[:valor_cruzamento_media_2] = valor_media
            end

          end
        end
      end

      valor_total = 0
      indice = indice + 1
    end
  end

  def calcula_media_movel_exponencial(cotacoes, periodos, tipo)

    valor_total = 0
    calculou_primeiro = false
    periodo = 1
    mme_anterior = 0
    k = 0.00

    cotacoes.each do |cotacao|

      if tipo == 1
        if cotacao[:valor_media].nil?
           cotacao[:valor_media] = 0.00
        end
      elsif tipo == 2
        if cotacao[:valor_cruzamento_media_1].nil?
           cotacao[:valor_cruzamento_media_1] = 0.00
        end
      elsif tipo == 3
        if cotacao[:valor_cruzamento_media_2].nil?
           cotacao[:valor_cruzamento_media_2] = 0.00
        end
      end

      if not calculou_primeiro

        valor_total = valor_total + cotacao[:valor_fechamento]

        if periodo == periodos
          valor_media = valor_total / periodos

          if tipo == 1
            cotacao[:valor_media] = valor_media
          elsif tipo == 2
            cotacao[:valor_cruzamento_media_1] = valor_media
          elsif tipo == 3
            cotacao[:valor_cruzamento_media_2] = valor_media
          end

          mme_anterior = valor_media
          calculou_primeiro = true
        end
        periodo = periodo + 1
      else
        k = (2.0 / (periodos + 1))
        mme = (cotacao[:valor_fechamento] * k) + (mme_anterior * (1.0 - k))

        if tipo == 1
          cotacao[:valor_media] = mme
        elsif tipo == 2
          cotacao[:valor_cruzamento_media_1] = mme
        elsif tipo == 3
          cotacao[:valor_cruzamento_media_2] = mme
        end

        mme_anterior = mme
      end
    end
  end


  def calcula_ifr(cotacoes, periodos)

    indice = 0

    cotacoes.each do |cotacao|

      valor_alta = 0
      valor_baixa = 0

      (1..periodos).each do |periodo|

        cot = cotacoes.at(indice + (periodo - 1))

        if not cot.nil?
          if cot.tipo_candle == "A"
            valor_alta = valor_alta + cot[:close]
          end
          if cot.tipo_candle == "B"
            valor_baixa = valor_baixa + cot[:close]
          end

          if periodo == periodos
            valor_media_alta = valor_alta > 0 ? valor_alta / periodos : 0
            valor_media_baixa = valor_baixa > 0 ? valor_baixa / periodos : 0

            valor_ifr = 100 - (100 / (1 + (valor_media_alta / valor_media_baixa)))

            cot[:valor_ifr] = valor_ifr
          end
        end
      end

      indice = indice + 1
    end
  end

  def calcula_totais()
    total_padroes_vencedores = 0
    total_padroes_perdedores = 0
    total_padroes_perdedores_em_sequencia = 0
    total_padroes_validados = 0
    total_padroes_em_aberto = 0
    total_padroes_encontrados = 0

    padroes_perdedores_em_sequencia = 0

    total_valor_padroes_em_aberto = 0
    total_valor_padroes_vencedores = 0
    total_valor_padroes_perdedores = 0

    @resumo_por_trade.each do |trade|

      total_padroes_encontrados = total_padroes_encontrados + 1
      if trade[:status] == "VALIDADO" ||
         trade[:status] == "ESTOPADO" ||
         trade[:status] == "VENDIDO"
        total_padroes_validados = total_padroes_validados + 1

        if trade[:lotes_a_vender] > 0
          total_padroes_em_aberto = total_padroes_em_aberto + 1
          total_valor_padroes_em_aberto = total_valor_padroes_em_aberto + trade[:valor_total_em_aberto]

        elsif trade[:valor_total_compra] > trade[:valor_total_venda]
          total_padroes_perdedores = total_padroes_perdedores + 1
          total_valor_padroes_perdedores = total_valor_padroes_perdedores + (trade[:valor_total_compra] - trade[:valor_total_venda])

          padroes_perdedores_em_sequencia = padroes_perdedores_em_sequencia + 1
          if padroes_perdedores_em_sequencia > total_padroes_perdedores_em_sequencia
            total_padroes_perdedores_em_sequencia = padroes_perdedores_em_sequencia
          end

        else
          total_padroes_vencedores = total_padroes_vencedores + 1
          total_valor_padroes_vencedores = total_valor_padroes_vencedores + (trade[:valor_total_venda] - trade[:valor_total_compra])
          padroes_perdedores_em_sequencia = 0
        end
      end
    end

    if total_padroes_vencedores > 0
      percentual_de_acerto = (total_padroes_vencedores * 100) / total_padroes_validados
      valor_ganho_medio_padroes_vencedores = total_valor_padroes_vencedores / total_padroes_vencedores
    else
      percentual_de_acerto = 0
      valor_ganho_medio_padroes_vencedores = 0
    end

    if total_padroes_perdedores > 0
      valor_perda_media_padroes_perdedores = (total_valor_padroes_perdedores / total_padroes_perdedores) * (-1)
    else
      valor_perda_media_padroes_perdedores = 0
    end

    total_valor_padroes_perdedores = total_valor_padroes_perdedores * (-1)
    saldo_final = total_valor_padroes_em_aberto + @saldo

    retorno = {
      :total_padroes_encontrados => total_padroes_encontrados,
      :total_padroes_validados => total_padroes_validados,
      :total_padroes_vencedores => total_padroes_vencedores,
      :total_padroes_perdedores => total_padroes_perdedores,
      :total_padroes_em_aberto => total_padroes_em_aberto,
      :total_padroes_perdedores_em_sequencia => total_padroes_perdedores_em_sequencia,
      :total_valor_padroes_vencedores => total_valor_padroes_vencedores,
      :total_valor_padroes_perdedores => total_valor_padroes_perdedores,
      :saldo_trades_em_aberto => total_valor_padroes_em_aberto,
      :saldo_trades_finalizados => @saldo,
      :saldo_final => saldo_final,
      :percentual_de_acerto => percentual_de_acerto,
      :valor_ganho_medio_padroes_vencedores => valor_ganho_medio_padroes_vencedores,
      :valor_perda_media_padroes_perdedores => valor_perda_media_padroes_perdedores
              }
    return retorno
  end

  def verifica_padrao(  cotacoes,
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
                        quantidade_maxima_de_candles_do_trade
                        )

    retorno = encontrar_padroes_de_candles_do_setup(cotacoes, indice, setup[:id], quantidade_maxima_de_candles_do_trade)

    if not retorno[:encontrei]
      return nil
    end

    if not valida_relacao_entre_candles(retorno[:candles_do_padrao], setup[:id])
      return nil
    end

    quantidade_candles_do_padrao = retorno[:candles_do_padrao].length

    valor_ponto_de_entrada = identifica_valor_ponto_de_entrada(pe1_valor, pe1_acima_abaixo, pe1_ponto_do_candle, pe1_qual_candle, retorno[:candles_do_padrao])
    valor_ponto_de_stop = identifica_valor_ponto_de_stop(pstop1, pstop2, pstop3, pstop4, retorno[:candles_do_padrao])
    valor_ponto_de_saida = identifica_valor_ponto_de_saida(valor_ponto_de_entrada, ps1)
    dados_do_proximo_candle_apos_padrao = identifica_dados_do_proximo_candle_apos_padrao(retorno[:candles_apos_padrao], pe1_ponto_de_entrada, quantidade_candles_do_padrao)

    cot1 = cotacoes.at(indice)

    trade = {   :id => id_do_padrao,
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
                :candles_do_padrao => retorno[:candles_do_padrao],
                :candles_apos_padrao => retorno[:candles_apos_padrao],
                :risco_do_trade => 0
              }
    @resumo_por_trade << trade
  end


  def valida_padrao( trade,
                          data,
                          ponto_zerar_risco_percentual,
                          valor_perda_trade,
                          valor_perda_geral,
                          valor_corretagem,
                          setup,
                          ifr_enabled,
                          ifr_local,
                          ifr_valor,
                          mm_enabled,
                          mm_local,
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

    if data == trade[:data_da_compra]

      #Padrão NAO validado => Nao existe candle apos padrao
      if status.nil? && trade[:valor_para_validar_padrao] == 0
        status = "NAO VALIDADO"
        historico = "Nao existem candles apos o padrao para validar."
      end

      #Padrão NAO validado => Nao existe ponto de entrada informado
      if status.nil? && trade[:valor_ponto_compra] == 0
        status = "NAO VALIDADO"
        historico = "Nao existe ponto de entrada definido."
      end

      #Padrao NAO validado. Candle após padrao nao ultrapassou valor de compra do padrao.
      if status.nil? && trade[:valor_para_validar_padrao] <= trade[:valor_ponto_compra]
        status = "NAO VALIDADO"
        historico = "O candle do dia "
        historico << trade[:data_da_compra].strftime("%d/%m/%Y")
        historico << " nao "
        historico << trade[:tipo_validacao] + " em "
        historico << number_to_currency(trade[:valor_ponto_compra]) << ". "
      end

      #--Valor a ser comprado, mais o valor de compras em aberto nao pode ser maior
      #--que o valor maximo cadastrado de perda (2% ou R$2.000,00 => base R$100.000,00)
      if status.nil?
        lotes_comprados = valor_perda_trade / (trade[:valor_ponto_compra].to_f - trade[:valor_ponto_stop].to_f)
        lotes_comprados = lotes_comprados / nr_lote_minimo
        lotes_comprados = nr_lote_minimo * lotes_comprados

        valor_total_compra = trade[:valor_ponto_compra].to_f * lotes_comprados
        valor_total_compra = valor_total_compra + valor_corretagem.to_f

        risco_do_trade = valor_total_compra - (lotes_comprados * trade[:valor_ponto_stop].to_f)

        if lotes_comprados <= 0
          status = "VALIDADO/NAO COMPRADO"
          historico = "Nao foi possivel calcular quantidade de lotes a comprar. "
        end
      end

      #--Valor a ser comprado, mais o valor de compras em aberto nao pode ser maior
      #--que o valor maximo cadastrado de perda (6% ou R$6.000,00 => base R$100.000,00)
      if perda_geral_enabled && status.nil?
        if @risco_acumulado + risco_do_trade > valor_perda_geral
          status = "VALIDADO/NAO COMPRADO"
          historico = "Risco geral ultrapassou o maximo permitido de " + number_to_currency(valor_perda_geral) + "."
        else
          lotes_comprados = (valor_perda_geral.to_f + valor_corretagem.to_f) / (trade[:valor_ponto_compra].to_f - trade[:valor_ponto_stop].to_f)
          lotes_comprados = lotes_comprados / nr_lote_minimo
          lotes_comprados = nr_lote_minimo * lotes_comprados

          valor_total_compra = trade[:valor_ponto_compra] * lotes_comprados
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

      #Verifica o IFR dos candles do padrao
      if status.nil? && ifr_enabled
        retorno = valida_ifr( trade[:candles_do_padrao], setup, ifr_local, ifr_valor)
        if not retorno[:encontrei]
          status = "VALIDADO/NAO COMPRADO"
          historico = retorno[:historico]
        end
      end

      if status.nil? && mm_enabled
        retorno = valida_media_movel(trade[:candles_do_padrao], setup, mm_enabled, mm_local)
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
          perc_risco_acumulado = (@risco_acumulado * 100) / @valor_investimento

          status = "VALIDADO"
          historico = "Candle do dia "
          historico << trade[:data_da_compra].strftime("%d/%m/%Y") << " "
          historico << trade[:tipo_validacao] + " em " + number_to_currency(trade[:valor_ponto_compra]) + ". "
          historico << "Comprados " + lotes_comprados.to_s + " lotes "
          historico << "com investimentos de " << number_to_currency(valor_total_compra) << ". "
          historico << "Risco do trade de " + number_to_currency(risco_do_trade) << "."

          trade[:risco_do_trade] = risco_do_trade

          @extrato << Backtest.insere_lancamentos_no_extrato(trade[:data_da_compra], valor_total_compra, "C", trade[:id], @saldo, risco_do_trade, @risco_acumulado)
        else
          status = "NAO VALIDADO"
          historico = "Valor de lotes comprados invalido."
        end
      end
    end

    retorno = { :status => status,
                :lotes_comprados => lotes_comprados,
                :lotes_para_zerar_risco => lote_zerar_risco,
                :valor_ponto_zerar_risco => valor_venda_alijar_risco,
                :valor_total_compra => valor_total_compra,
                :historico => {:title => status, :description => historico } }

    return  retorno
  end


  def valida_relacao_entre_candles(candles_do_padrao, setup_id)

    setup_rels = lista_relacionamentos_entre_candles(setup_id)
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


  def valida_ifr(candles_do_padrao, setup, ifr_local, ifr_valor)

    setup = Setup.busca_setup(setup[:id])

    candles_do_padrao.each do |candle|

      if ifr_local.upcase == "ABAIXO"
        if candle[:valor_ifr].to_f > ifr_valor.to_f
          retorno = { :encontrei => false,
                      :historico => "Candle do dia " << candle[:data].strftime("%d/%m/%Y") << " apresenta um IFR de " << candle[:valor_ifr].to_s << " maior que " << ifr_valor.to_s << ". "          }
          return retorno
        end
      end

      if ifr_local.upcase == "ACIMA"
        if candle[:valor_ifr].to_f < ifr_valor.to_f
          retorno = {
            :encontrei => false,
            :historico => "Candle do dia " << candle[:data].strftime("%d/%m/%Y") << " apresenta um IFR de " << candle[:valor_ifr].to_s << " menor que " << ifr_valor.to_s << ". "
          }
          return retorno
        end
      end
    end
    retorno = {
      :encontrei => true,
      :historico => ""
    }
    return retorno
  end


  def valida_media_movel(candles_do_padrao, setup, mm_enabled, mm_local)

    setup = Setup.busca_setup(setup[:id])

    encontrei = true
    historico = ""

    candles_do_padrao.each do |candle|

      if encontrei && mm_enabled
        ## Padrao ocorre ACIMA da MM
        if mm_local.upcase == 'ACIMA'
          if candle[:valor_minima] > candle[:valor_media] || candle[:valor_media] == 0
            encontrei = true
          else
            historico = "Candle do dia " << candle[:data].strftime("%d/%m/%Y") << "  nao esta ACIMA da media movel. Valor da minima (" << candle[:valor_minima].to_s << ") e menor que valor da media movel (" << candle[:valor_media].to_s << ")."
            encontrei = false
            break
          end
        end

        ## Padrao ocorre ABAIXO da MM
        if mm_local.upcase == 'ABAIXO'
          if candle[:valor_maxima] < candle[:valor_media] || candle[:valor_media] == 0
            encontrei = true
          else
            historico = "Valor da maxima (" << candle[:valor_maxima].to_s << ") do dia " << candle[:data].to_s << " esta abaixo do valor da media (" << candle[:valor_media].to_s << ")."
            encontrei = false
            break
          end
        end

        ## Padrao ocorre SOBRE a MM
        if mm_local.upcase == 'SOBRE'
          if candle[:valor_media] == 0
            encontrei = true
          elsif candle[:valor_minima] < candle[:valor_media] && candle[:valor_maxima] > candle[:valor_media]
            encontrei = true
          else
            historico = "Media movel (" << candle[:valor_media].to_s << ") nao esta passando sobre o candle do dia " << candle[:data].strftime("%d/%m/%Y") << ", onde a maxima e " << candle[:valor_maxima].to_s << " e a minima e " << candle[:valor_minima].to_s << "."
            encontrei = false
            break
          end
        end
      end
    end
    retorno = { :encontrei => encontrei,
                :historico => historico }
    return retorno
  end


#  def valida_tipo_cada_candle_padrao(cotacoes, indice, setup_id, quantidade_maxima_candles_do_trade)
  def encontrar_padroes_de_candles_do_setup(cotacoes, indice, setup_id, quantidade_maxima_candles_do_trade)

    setup = Setup.busca_setup(setup_id)
    candles_do_padrao = []
    candles_apos_padrao = []
    encontrei = true

    qtd_candles_do_padrao = setup[:quantity_candle].to_i

    (1..qtd_candles_do_padrao).each  do |index|

      if index == 1
        setup_candle_status = setup[:first_candle]
        setup_candle_tipo = setup[:first_candle_type]
      elsif index == 2
        setup_candle_status = setup[:second_candle]
        setup_candle_tipo = setup[:second_candle_type]
      elsif index == 3
        setup_candle_status = setup[:third_candle]
        setup_candle_tipo = setup[:third_candle_type]
      end

      setup_candle_tipo = "" if setup_candle_tipo.nil?

      cot = cotacoes.at(indice + (index - 1))

      if cot.nil?
        encontrei = false
        break
      end

      #Verifica o tipo de cada candle A=Alta, B=Baixa ou "N"=Sei la
      if cot.type_candle == setup_candle_status || setup_candle_status == "N"
        encontrei = true
        candles_do_padrao << {:date_quotation => cot.date_quotation,
                              :open => cot.open,
                              :close => cot.close,
                              :low => cot.low,
                              :high => cot.high,
                              :valor_ifr => 0,
                              :valor_media => 0
                              }
      else
        encontrei = false
        break
      end

      #Verifica se candle eh MARTELO
      if setup_candle_tipo.downcase == 'martelo'

        if cot.type_candle == "A"
          valor_sombra_inferior = cot.open - cot.low
          valor_sombra_superior = cot.high - cot.close
        else
          valor_sombra_inferior = cot.close - cot.low
          valor_sombra_superior = cot.high - cot.open
        end

        valor_corpo = cot.open - cot.close
        valor_corpo = valor_corpo.abs

        if valor_sombra_inferior > (valor_corpo * 2) && valor_sombra_superior < valor_corpo
          encontrei = true
        else
          encontrei = false
          break
        end
      end
    end

    #Busca candles após o padrão
    if encontrei
      pos_inicial = candles_do_padrao.length + 1
      pos_final = pos_inicial + (quantidade_maxima_candles_do_trade.to_i - 1)

      (pos_inicial..pos_final).each  do |position_candle|
        cot = cotacoes.at(indice + (position_candle - 1))

        if cot.nil?
          encontrei = false
          break
        end

        candles_apos_padrao << {:date_quotation => cot.date_quotation,
                                :open => cot.open,
                                :close => cot.close,
                                :low => cot.low,
                                :high => cot.high
                                }
       end
    end

    retorno = { :encontrei => encontrei,
                :candles_do_padrao => candles_do_padrao,
                :candles_apos_padrao => candles_apos_padrao
              }
    return retorno
  end


  def identifica_valor_ponto_de_entrada(pe1_valor, pe1_acima_abaixo, pe1_ponto_do_candle, pe1_qual_candle, candles)
    #testado.
    return nil if pe1_valor == 0

    p = Backtest.carrega_lista_ponto_do_candle
    if  p[0][1]  !=  pe1_ponto_do_candle &&
        p[1][1]  !=  pe1_ponto_do_candle &&
        p[2][1]  !=  pe1_ponto_do_candle &&
        p[3][1]  !=  pe1_ponto_do_candle
      return nil
    end

    position_candle = pe1_qual_candle.to_i

    cot = candles[(position_candle - 1)]

    if pe1_ponto_do_candle == "high"
      valor_entrada_padrao = cot[:high]
    elsif pe1_ponto_do_candle == "low"
      valor_entrada_padrao = cot[:low]
    elsif pe1_ponto_do_candle == "open"
      valor_entrada_padrao = cot[:open]
    elsif pe1_ponto_do_candle == "close"
      valor_entrada_padrao = cot[:close]
    else
      return nil
    end

    #pe3 => "acima", "abaixo"
    valor_a_ser_somado = 0
    if pe1_acima_abaixo == "acima"
      valor_a_ser_somado = pe1_valor.to_f
    elsif pe1_acima_abaixo == "abaixo"
      valor_a_ser_somado = pe1_valor.to_f * (-1)
    end

    valor_entrada_padrao = valor_entrada_padrao + valor_a_ser_somado

    return valor_entrada_padrao
  end


  def identifica_valor_ponto_de_stop(pstop1, pstop2, pstop3, pstop4, candles_do_padrao)

    #pstop4 => "primeiro", "segundo", "terceiro" candle
    position_candle = pstop4.to_i

#    cot = cotacoes.at(indice + (position_candle - 1))
    cot = candles_do_padrao[(position_candle - 1)]

    #pstop3 => "da máxima", "da mínima", "do fechamento", "da abertura"
    if pstop3 == "maxima"
      valor_ponto_de_stop = cot[:high]
    elsif pstop3 == "minima"
      valor_ponto_de_stop = cot[:low]
    elsif pstop3 == "abertura"
      valor_ponto_de_stop = cot[:open]
    else
      valor_ponto_de_stop = cot[:close]
    end

    #pstop2 => "acima", "abaixo"
    valor_a_ser_somado = 0
    if pstop2 == "acima"
      valor_a_ser_somado = pstop1.to_f
    elsif pstop2 == "abaixo"
      valor_a_ser_somado = pstop1.to_f * (-1)
    end

    valor_ponto_de_stop = valor_ponto_de_stop + valor_a_ser_somado

    return valor_ponto_de_stop
  end


  def identifica_valor_ponto_de_saida(valor_ponto_de_entrada, ps1)
    valor_ponto_de_saida = valor_ponto_de_entrada + (valor_ponto_de_entrada * ( ps1.to_f / 100 ))
    return valor_ponto_de_saida
  end


  def identifica_dados_do_proximo_candle_apos_padrao(candles_apos_padrao, pe1, quantidade_candles_do_padrao)
    cot = candles_apos_padrao[0]

    if not cot.nil?
      #pe_1 => "ao_atingir", "Ao fechar"
      if pe1 == "ao_atingir"
        valor = cot[:high]
        tipo_validacao = "atingiu o Ponto de Entrada "
      else
        valor = cot[:close]
        tipo_validacao = "fechou acima do Ponto de Entrada "
      end
      data_compra = cot[:date_quotation]
    else
      valor = 0
      tipo_validacao = nil
      data_compra = nil
    end

    dados = { :valor_para_validar_padrao => valor,
              :tipo_validacao => tipo_validacao,
              :data_da_compra => data_compra }
    return dados
  end

  def lista_relacionamentos_entre_candles(setup_id)
    return SetupRel.where('setup_id = ?', setup_id)
  end

  def carrega_lista_ponto_do_candle
    ponto_do_candle = [['da maxima','high'], ['da minima','low'], ['da abertura','open'], ['do fechamento','close']]
  end

  def carrega_lista_ponto_do_candle2
    ponto_do_candle = [['da minima','low'], ['da maxima','high'], ['da abertura','open'], ['do fechamento','close']]
  end

  def carrega_lista_acima_abaixo
    ret = [['acima','acima'],['abaixo','abaixo']]
  end

  def carrega_lista_abaixo_acima
    ret = [['abaixo','abaixo'],['acima','acima']]
  end

  def carrega_lista_ponto_de_entrada
    ret = [['Ao atingir','ao_atingir'],['Ao fechar','ao_fechar']]
  end

end
