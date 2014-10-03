require 'rails_helper'

describe Validate do
  before(:each) do
    create(:setup, id: 1, setup: 'Harami de Alta', description: 'Harami de Alta', quantity_candle: 2, first_candle: 'B', second_candle: 'A', third_candle: 'N')
    create(:setup, id: 2, setup: 'Candle de Alta', description: 'Candle de Alta', quantity_candle: 1, first_candle: 'A', second_candle: 'N', third_candle: 'N')

    create(:setup_rel, id: 1, setup_id: 1, candle_x_value: 'abertura', candle_x_position: 'primeiro', value: 'maior', candle_y_value: 'fechamento', candle_y_position: 'segundo' )
    create(:setup_rel, id: 2, setup_id: 1, candle_x_value: 'fechamento', candle_x_position: 'primeiro', value: 'menor', candle_y_value: 'abertura', candle_y_position: 'segundo' )

    create(:daily_quotation, id: 1, date_quotation: Date.new(2012,3,11), open: 20, close: 10, low: 8, high: 23, paper: "PETR4.SA", type_candle: "B" )
    create(   :daily_quotation,
              :id => 2,
              :date_quotation => Date.new(2012,3,12),
              :open => 12,
              :close => 18,
              :low => 8,
              :high => 22,
              paper: "PETR4.SA",
              type_candle: "A" )
    create(   :daily_quotation,
              :id => 3,
              :date_quotation => Date.new(2012,3,13),
              :open => 18,
              :close => 30,
              :low => 8,
              :high => 30,
              paper: "PETR4.SA",
              type_candle: "A")
    create(   :daily_quotation,
              :id => 4,
              :date_quotation => Date.new(2012,3,14),
              :open => 25,
              :close => 20,
              :low => 8,
              :high => 30,
              paper: "PETR4.SA",
              type_candle: "B")
    create(   :daily_quotation,
              :id => 5,
              :date_quotation => Date.new(2012,3,15),
              :open => 20,
              :close => 25,
              :low => 8,
              :high => 30,
              paper: "PETR4.SA",
              type_candle: "A")
    create(   :daily_quotation,
              :id => 6,
              :date_quotation => Date.new(2012,3,15),
              :open => 24,
              :close => 20,
              :low => 8,
              :high => 30,
              paper: "PETR4.SA",
              type_candle: "B")
  end

  it  'verify candle_i5'  do
    candles = DailyQuotation.all

    candle = Validate.candle_i5(candles, [0,1], 2)
    expect(candle[:id]).to eq 2
    candle = Validate.candle_i5(candles, [3,4], 1)
    expect(candle[:id]).to eq 4
  end

  it 'point_for_validate' do
    candles = DailyQuotation.all

#    create(:daily_quotation, id: 1, date_quotation: Date.new(2012,3,11), open: 20, close: 10, low: 8, high: 23, paper: "PETR4.SA", type_candle: "B" )
    ret = Validate.point_for_validate( 0, 'acima', 'high', candles[0])
    expect(ret).to eq nil
    ret = Validate.point_for_validate( 1, 'acima', 'high', candles[0])
    expect(ret).to eq 24
    ret = Validate.point_for_validate( 1, 'abaixo', 'high', candles[0])
    expect(ret).to eq 22
    ret = Validate.point_for_validate( 1, 'acima', 'low', candles[0])
    expect(ret).to eq 9
    ret = Validate.point_for_validate( 1, 'abaixo', 'low', candles[0])
    expect(ret).to eq 7
    ret = Validate.point_for_validate( 1, 'acima', 'close', candles[0])
    expect(ret).to eq 11
    ret = Validate.point_for_validate( 1, 'abaixo', 'close', candles[0])
    expect(ret).to eq 9
    ret = Validate.point_for_validate( 1, 'acima', 'open', candles[0])
    expect(ret).to eq 21
    ret = Validate.point_for_validate( 1, 'abaixo', 'open', candles[0])
    expect(ret).to eq 19
  end

  it 'validate' do
    candles = DailyQuotation.all

    ret = Validate.validate(candles, [[0,1], [3,4]], 'ao_atingir', 1, 'acima', 'high', 2)
    expect(ret.size).to eq 2

    expect(ret[0][:setup]).to eq [0,1]
    expect(ret[0][:status]).to eq "VALIDADO"

    expect(ret[1][:setup]).to eq [3,4]
    expect(ret[1][:status]).to eq "NAO VALIDADO"


  end

end
