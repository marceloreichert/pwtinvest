module Backtest
  include ActionView::Helpers::NumberHelper

  def self.backtest  (ticks,
                      mm_enabled,
                      params = {} )

    paper                           = params[:paper]
    setup_id                        = params[:setup][:id]
    pe1_ponto_de_entrada            = params[:pe1_ponto_de_entrada]
    pe1_valor                       = params[:pe1_valor]
    pe1_acima_abaixo                = params[:pe1_acima_abaixo]
    pe1_ponto_do_candle             = params[:pe1_ponto_do_candle]
    pe1_qual_candle                 = params[:pe1_qual_candle]
    ponto_stop_valor                = params[:ponto_stop_valor]
    ponto_stop_acima_abaixo         = params[:ponto_stop_acima_abaixo]
    ponto_stop_ponto_do_candle      = params[:ponto_stop_ponto_do_candle]
    ponto_stop_lista_de_candles     = params[:ponto_stop_lista_de_candles]
    quantidade_maxima_candle_trade  = params[:quantidade_maxima_candle_trade]
    ponto_saida_valor               = params[:ponto_saida_valor]
    perc_perda_trade                = params[:perc_perda_trade]
    perc_perda_geral                = params[:perc_perda_geral]
    vlr_investiment                 = params[:valor_investimento]
    ponto_zerar_risco_percentual    = params[:ponto_zerar_risco_percentual]
    prazo                           = params[:prazo]
    valor_corretagem                = params[:valor_corretagem]
    perda_geral_enabled             = params[:perda_geral_enabled]


    setups_found  = Finder.find( ticks, setup_id )
    setups_found  = Relation.relation( ticks, setups_found, setup_id)
    setups_valid  = Validate.validate( ticks, setups_found, pe1_ponto_de_entrada, pe1_valor, pe1_acima_abaixo, pe1_ponto_do_candle, pe1_qual_candle )

#    quantidade_candles_do_padrao = ret[:candles_on_setup].length
#    valor_ponto_de_entrada = Backtest.identifica_valor_ponto_de_entrada(pe1_valor, pe1_acima_abaixo, pe1_ponto_do_candle, pe1_qual_candle, ret[:candles_on_setup])
#    valor_ponto_de_stop = Backtest.identifica_valor_ponto_de_stop(pstop1, pstop2, pstop3, pstop4, ret[:candles_on_setup])
#    valor_ponto_de_saida = Backtest.identifica_valor_ponto_de_saida(valor_ponto_de_entrada, ps1)
#    dados_do_proximo_candle_apos_padrao = Backtest.identifica_dados_do_proximo_candle_apos_padrao(ret[:candles_after_setup], pe1_ponto_de_entrada, quantidade_candles_do_padrao)

    @list  = []

    tick_verified = []
    @vlr_investiment = vlr_investiment.to_f
    @saldo = vlr_investiment.to_f
    @risco_acumulado = 0
    valor_perda_trade = @saldo * (perc_perda_trade.to_f / 100) # 100.000,00 * 2% = 2.000,00
    valor_perda_geral = @saldo * (perc_perda_geral.to_f / 100) # 100.000,00 * 6% = 6.000,00

    @list   << insert_list( nil, 0.00, "I", nil, @saldo, 0.00, 0.00)
    indice  = 0

    @ticks.each do |tick|

      tick_verified.each do |t|

        if t[:status] == "ENCONTRADO"


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
            if tick.low < t[:valor_ponto_stop]

              valor_total_venda = t[:valor_ponto_stop] * t[:lotes_a_vender]
              valor_total_venda = valor_total_venda - valor_corretagem.to_f

              @saldo = @saldo + valor_total_venda

              if t[:lotes_a_vender] == t[:lotes_comprados]
                @risco_acumulado = @risco_acumulado - t[:risco_do_trade]
              end

              t[:status] = "ESTOPADO"
              t[:valor_total_em_aberto] = t[:valor_total_em_aberto] - valor_total_venda
              t[:valor_total_venda] = t[:valor_total_venda] + valor_total_venda

              @list << insert_list( tick.date_quotation, valor_total_venda, "V", t[:id], @saldo, t[:risco_do_trade], @risco_acumulado)

              historico = "Candle do dia "
              historico << tick.date_quotation.strftime("%d/%m/%Y")
              historico << " atingiu o Ponto de Stop Loss em "
              historico << number_to_currency(t[:valor_ponto_stop]) + ". "
              historico << "Vendidos " + t[:lotes_a_vender].to_s + " lotes com retorno de "
              historico << number_to_currency(valor_total_venda)
              t[:historico] << {:title => "ESTOPADO", :description => historico }
              t[:lotes_a_vender] = 0
            end

            #Verifica VENDA para ZERAR RISCO
            if t[:valor_ponto_zerar_risco] > 0 && t[:lotes_a_vender] > 0
              if tick.high >= t[:valor_ponto_zerar_risco]

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

                @list << insert_list( tick.date_quotation, valor_total_venda, "V", t[:id], @saldo, risco_do_trade, @risco_acumulado)

                historico = "Candle do dia " + tick.date_quotation.strftime("%d/%m/%Y")
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
            if tick.high >= t[:valor_ponto_venda]

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

              @list << insert_list( tick.date_quotation, valor_total_venda, "V", t[:id], @saldo, risco_do_trade, @risco_acumulado)

              historico = "Candle do dia " + tick.date_quotation.strftime("%d/%m/%Y")
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
              valor_saida = tick.close * t[:lotes_a_vender]
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

              @list << insert_list( tick.date_quotation, valor_saida, "V", t[:id], @saldo, risco_do_trade, @risco_acumulado)

              historico = "Ponto de Saida ou Stop Loss nao atingidos. "
              historico << "Vendidos " + t[:lotes_a_vender].to_s + " lotes "
              historico << "no fechamento do ultimo candle do trade, "
              historico << "no dia "
              historico << tick.date_quotation.strftime("%d/%m/%Y")
              historico << ", por "
              historico << tick.close.to_s
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

    @list   = Backtest.set_counter(@list)
    @totais = calcula_totais(tick_verified)

    retorno = { :trade => tick_verified,
                :extrato => @extrato,
                :totais => @totais }

    return  retorno
  end





  def self.set_counter(list)
    if list.count > 0
      for i in 1..list.count
        list[i-1][:lancamento] = i
      end
    end
    list
  end

  def self.gera_xml_do_grafico(dados, label, quantidade_candles)
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


  def self.calcula_totais(tick_verified)
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

    tick_verified.each do |tick|

      total_padroes_encontrados = total_padroes_encontrados + 1
      if tick[:status] == "VALIDADO" ||
         tick[:status] == "ESTOPADO" ||
         tick[:status] == "VENDIDO"
        total_padroes_validados = total_padroes_validados + 1

        if tick[:lotes_a_vender] > 0
          total_padroes_em_aberto = total_padroes_em_aberto + 1
          total_valor_padroes_em_aberto = total_valor_padroes_em_aberto + tick[:valor_total_em_aberto]

        elsif tick[:valor_total_compra] > tick[:valor_total_venda]
          total_padroes_perdedores = total_padroes_perdedores + 1
          total_valor_padroes_perdedores = total_valor_padroes_perdedores + (tick[:valor_total_compra] - tick[:valor_total_venda])

          padroes_perdedores_em_sequencia = padroes_perdedores_em_sequencia + 1
          if padroes_perdedores_em_sequencia > total_padroes_perdedores_em_sequencia
            total_padroes_perdedores_em_sequencia = padroes_perdedores_em_sequencia
          end

        else
          total_padroes_vencedores = total_padroes_vencedores + 1
          total_valor_padroes_vencedores = total_valor_padroes_vencedores + (tick[:valor_total_venda] - tick[:valor_total_compra])
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






  def self.valida_media_movel(candles_do_padrao, setup, mm_enabled, mm_local)
  ## TESTED
    setup = Setup.load(setup[:id])

    ok = true
    historico = ""

    candles_do_padrao.each do |candle|

      if ok && mm_enabled
        historico = valid(mm_local, candle)
        ok = historico.empty? ? true : false
      end
    end

    return { encontrei: ok, historico: historico }
  end


  def self.identifica_valor_ponto_de_stop(pstop1, pstop2, pstop3, pstop4, candles_do_padrao)

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


  def self.identifica_valor_ponto_de_saida(valor_ponto_de_entrada, ps1)
    valor_ponto_de_saida = valor_ponto_de_entrada + (valor_ponto_de_entrada * ( ps1.to_f / 100 ))
    return valor_ponto_de_saida
  end


  def self.identifica_dados_do_proximo_candle_apos_padrao(candles_apos_padrao, pe1, quantidade_candles_do_padrao)
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



  def self.carrega_lista_ponto_de_entrada
    ret = [['Ao atingir','ao_atingir'],['Ao fechar','ao_fechar']]
  end

  def self.carrega_lista_ponto_do_candle2
    ponto_do_candle = [['da minima','low'], ['da maxima','high'], ['da abertura','open'], ['do fechamento','close']]
  end

  def self.carrega_lista_acima_abaixo
    ret = [['acima','acima'],['abaixo','abaixo']]
  end

  def self.carrega_lista_abaixo_acima
    ret = [['abaixo','abaixo'],['acima','acima']]
  end


  def self.insert_list(data, valor, tipo, id, saldo, risco_do_trade, risco_acumulado)
    return  {   lancamento: 0,
                data: data,
                valor: valor,
                tipo: tipo,
                id: id,
                saldo: saldo,
                risco_do_trade: risco_do_trade,
                risco_acumulado: risco_acumulado }
  end



  private

  def self.valid(type, options={})
    if type.upcase == 'ACIMA'
      if options[:low] <= options[:valor_media] && options[:valor_media] > 0
        return "Candle do dia " << options[:date_quotation].strftime("%d/%m/%Y") << " nao esta ACIMA da media movel."
      end

    elsif type.upcase == 'ABAIXO'
      if options[:high] >= options[:valor_media] && options[:valor_media] > 0
        return "Candle do dia " << options[:date_quotation].strftime("%d/%m/%Y") << " nao esta ACIMA da media movel."
      end

    elsif type.upcase == 'SOBRE'
      if options[:valor_media] > 0 && (options[:low] > options[:valor_media] || options[:high] < options[:valor_media])
        return "Candle do dia " << options[:date_quotation].strftime("%d/%m/%Y") << " nao esta SOBRE da media movel."
      end
    end

    return ''
  end
end
