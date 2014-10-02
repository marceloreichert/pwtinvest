class Finder

  def self.find( ticks, setup_id )
    filter(ticks, load_setup_types( setup_id ) )
  end

  def self.load_setup_types( setup_id )
      setup = Setup.load( setup_id )
      setup_types = []

      qtd_candle = setup[:quantity_candle].to_i
      (1..qtd_candle).each  do |candle|
          case candle
          when 1
              setup_types << setup[:first_candle]
          when 2
              setup_types << setup[:second_candle]
          when 3
              setup_types << setup[:third_candle]
          end
      end
      setup_types
  end

  def self.filter( ticks, types )
    ticks_filtered = []
    (0..ticks.size - 1).each do |index|
      tick = []
      (1..types.size).each do |candle|
          t = ticks.at(index + (candle - 1))
          if t.present? && t.type_candle == types[candle - 1]
            tick << index + (candle - 1)
          else
            tick = nil
            break
          end
      end

      t = ticks.at(index + types.size)
      tick = nil if t.nil?

      ticks_filtered << tick unless tick.nil?
    end
    ticks_filtered
  end
end
