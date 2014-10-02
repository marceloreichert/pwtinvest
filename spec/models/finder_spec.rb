require 'rails_helper'

describe Finder do
  before(:each) do
    create(:setup, id: 1, setup: 'Harami de Alta', description: 'Harami de Alta', quantity_candle: 2, first_candle: 'B', second_candle: 'A', third_candle: 'N')
    create(:setup, id: 2, setup: 'Candle de Alta', description: 'Candle de Alta', quantity_candle: 1, first_candle: 'A', second_candle: 'N', third_candle: 'N')

    create(:setup_rel, id: 1, setup_id: 1, candle_x_value: 'abertura', candle_x_position: 'primeiro', value: 'maior', candle_y_value: 'fechamento', candle_y_position: 'segundo' )
    create(:setup_rel, id: 2, setup_id: 1, candle_x_value: 'fechamento', candle_x_position: 'primeiro', value: 'menor', candle_y_value: 'abertura', candle_y_position: 'segundo' )

    create(   :daily_quotation,
              :id => 1,
              :date_quotation => Date.new(2012,3,11),
              :open => 20,
              :close => 10,
              :low => 8,
              :high => 23,
              paper: "PETR4.SA",
              type_candle: "B" )
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
              :close => 25,
              :low => 8,
              :high => 30,
              paper: "PETR4.SA",
              type_candle: "A")
    create(   :daily_quotation,
              :id => 7,
              :date_quotation => Date.new(2012,3,16),
              :open => 23,
              :close => 30,
              :low => 8,
              :high => 30,
              paper: "PETR4.SA",
              type_candle: "A")
  end

  it 'load setup types with 2 candles' do
    types = Finder.load_setup_types(1)
    expect(types.size).to eq 2
    expect(types[0]).to eq 'B'
    expect(types[1]).to eq 'A'
  end

  it 'load setup types with 1 candle' do
    types = Finder.load_setup_types(2)
    expect(types.size).to eq 1
    expect(types[0]).to eq 'A'
  end

  it 'filter with types A and B' do
    ticks     = DailyQuotation.where('paper = ?', 'PETR4.SA')
    filtered  = Finder.filter(ticks, ['B', 'A'])
    expect(filtered.size).to eq 2
    expect(filtered[0]).to eq [0, 1]
    expect(filtered[1]).to eq [3, 4]
  end

  it 'filter with only type A' do
    ticks     = DailyQuotation.where('paper = ?', 'PETR4.SA')
    filtered  = Finder.filter(ticks, ['A'])
    expect(filtered.size).to eq 4
    expect(filtered[0]).to eq [1]
    expect(filtered[1]).to eq [2]
    expect(filtered[2]).to eq [4]
    expect(filtered[3]).to eq [5]
  end

  it 'Validate setup with 2 candles' do
    ticks = DailyQuotation.where('paper = ?', 'PETR4.SA')
    t = Finder.find(ticks, 1)
    expect(t.size).to eq 2
    expect(t[0]).to eq [0, 1]
    expect(t[1]).to eq [3, 4]
  end

  it 'setup with 1 candle' do
    ticks = DailyQuotation.where('paper = ?', 'PETR4.SA')
    t = Finder.find(ticks, 2)
    expect(t.size).to eq 4
    expect(t[0]).to eq [1]
    expect(t[1]).to eq [2]
    expect(t[2]).to eq [4]
    expect(t[3]).to eq [5]
  end
end
