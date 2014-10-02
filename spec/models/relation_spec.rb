require 'rails_helper'

describe Relation do
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

  it 'exists relation between candles' do
    setup = Setup.load(1)
    expect(Relation.exist_relation?(setup)).to eq true
    setup = Setup.load(2)
    expect(Relation.exist_relation?(setup)).to eq false
  end

  it  'test relation between candles with 2 candles setup' do
    ticks = DailyQuotation.where('paper = ?', 'PETR4.SA')
    ticks_idx = [[0,1], [3,4]]
    ret = Relation.relation(ticks, ticks_idx, 1)
    expect(ret).to eq [[0,1]]
  end

  it  'test relation between candles with 1 candles setup' do
    ticks = DailyQuotation.where('paper = ?', 'PETR4.SA')
    ret = Relation.relation(ticks, [[0], [3]], 2)
    expect(ret).to eq [[0], [3]]
  end

end
