class Validate
  def self.validate(ticks, setup_found, pe1_ponto_de_entrada, pe1_valor, pe1_acima_abaixo, pe1_ponto_do_candle, pe1_qual_candle )

    setup_found.each  do |setup_idx|

      tick_ponto_de_entrada = ticks.at(setup_idx + pe1_qual_candle.to_i - 1)
      valor_ponto_entrada = ponto_de_entrada(pe1_valor, pe1_acima_abaixo, pe1_ponto_do_candle, pe1_qual_candle, tick_ponto_de_entrada)

      candle_depois_setup = ticks.at( setup_idx.size)

      if pe1_ponto_de_entrada == "ao_atingir"
        valor = candle_depois_setup[:high]
      else
        valor = candle_depois_setup[:close]
      end


      if valor <= valor_ponto_entrada
        status = "NAO VALIDADO"
        historico = "O candle do dia "
        historico << candle_depois_setup[:date_quotation].strftime("%d/%m/%Y")
        historico << " nao "
        historico << pe1_ponto_de_entrada + " ponto de entrada em "
        historico << number_to_currency(valor_ponto_entrada) << ". "
      end

      setup_validado << {setup: setup_idx, status: status, historico: historico}
    end
  end

  def self.ponto_de_entrada(pe1_valor, pe1_acima_abaixo, pe1_ponto_do_candle, pe1_qual_candle, tick_ponto_de_entrada)
    return nil if pe1_valor == 0

    p = carrega_lista_ponto_do_candle
    if  p[0][1]  !=  pe1_ponto_do_candle &&
        p[1][1]  !=  pe1_ponto_do_candle &&
        p[2][1]  !=  pe1_ponto_do_candle &&
        p[3][1]  !=  pe1_ponto_do_candle
      return nil
    end

    if pe1_ponto_do_candle == "high"
      valor_entrada_padrao = tick_ponto_de_entrada[:high]
    elsif pe1_ponto_do_candle == "low"
      valor_entrada_padrao = tick_ponto_de_entrada[:low]
    elsif pe1_ponto_do_candle == "open"
      valor_entrada_padrao = tick_ponto_de_entrada[:open]
    elsif pe1_ponto_do_candle == "close"
      valor_entrada_padrao = tick_ponto_de_entrada[:close]
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

  def self.carrega_lista_ponto_do_candle
    ponto_do_candle = [['da maxima','high'], ['da minima','low'], ['da abertura','open'], ['do fechamento','close']]
  end

end