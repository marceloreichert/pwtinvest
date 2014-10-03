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
  def self.validate(candles, setup_found, i1, i2, i3, i4, i5 )

    setup_validado  = []

    setup_found.each  do |setup_index|

      candle = candle_i5(candles, setup_index, i5)

      value_for_validate = point_for_validate(i2, i3, i4, candle )

      candle_after_setup = candles.at( setup_index.size)

      i1 == "ao_atingir" ? value = candle_after_setup[:high] : value = candle_after_setup[:close]

      if value_for_validate == 0
        status = "NAO VALIDADO"
        historico = "Nao encontrado valor para validar candle."
      end

      if value <= value_for_validate
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
  def self.candle_i5(candles, setup_found_index, i5)
    candles.at(setup_found_index[i5 - 1])
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

end