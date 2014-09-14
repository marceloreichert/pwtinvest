FactoryGirl.define do
  factory :setup do
    id 1
    setup 'Harami de Alta'
    description 'Harami de Alta'
    quantity_candle 2
    first_candle 'B'
    second_candle 'A'
    third_candle 'N'
    user_id 0
  end

  factory :setup_rel do
    id 1
    setup_id 1
    candle_x_value 'abertura'
    candle_x_position 'primeiro'
    value 'maior'
    candle_y_value 'fechamento'
    candle_y_position 'segundo'
  end

  factory :paper do
    id 1
    symbol 'PETR4.SA'
    description 'Petrobras'
    nr_lote 100
  end
end
