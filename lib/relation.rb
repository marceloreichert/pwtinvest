class Relation

  def self.relation( ticks, ticks_idx, setup_id)

    return ticks_idx unless exist_relation?( Setup.load(setup_id))

    setup_rels = SetupRel.load(setup_id)
    tick_filtered = []

    ticks_idx.each  do |tick|

      setup_rels.each do |relation|
        if relation.candle_x_position == 'primeiro'
          candle_x_position = 1
        elsif relation.candle_x_position == 'segundo'
          candle_x_position = 2
        elsif relation.candle_x_position == 'terceiro'
          candle_x_position = 3
        end

        if relation.candle_y_position == 'primeiro'
          candle_y_position = 1
        elsif relation.candle_y_position == 'segundo'
          candle_y_position = 2
        elsif relation.candle_y_position == 'terceiro'
          candle_y_position = 3
        end


        t = ticks.at(tick[candle_x_position - 1])

        if relation.candle_x_value == 'abertura'
          candle_x_value = t[:open]
        elsif relation.candle_x_value == 'fechamento'
          candle_x_value = t[:close]
        elsif relation.candle_x_value == 'maxima'
          candle_x_value = t[:high]
        elsif relation.candle_x_value == 'minima'
          candle_x_value = t[:low]
        end

        t = ticks.at(tick[candle_y_position - 1])

        if relation.candle_y_value == 'abertura'
          candle_y_value = t[:open]
        elsif relation.candle_y_value == 'fechamento'
          candle_y_value = t[:close]
        elsif relation.candle_y_value == 'maxima'
          candle_y_value = t[:high]
        elsif relation.candle_y_value == 'minima'
          candle_y_value = t[:low]
        end

        if relation.value == 'maior'
          unless candle_x_value > candle_y_value
            tick  = nil
            break
          end
        end

        if relation.value == 'menor'
          unless candle_x_value < candle_y_value
            tick  = nil
            break
          end
        end
      end
      tick_filtered <<  tick unless tick.nil?
    end
    return tick_filtered
  end

  def self.exist_relation?( setup )
    setup.quantity_candle == 1 ? false : true
  end

end
