require 'rails_helper'

describe Setup, :type => :model do

  before(:each) do
    create(:setup, id: 1, setup: 'Harami de Alta', description: 'Harami de Alta', quantity_candle: 2, first_candle: 'B', second_candle: 'A', third_candle: 'N')
    create(:setup, id: 2, setup: 'Martelo de Alta', description: 'Martelo de Alta', quantity_candle: 1, first_candle: 'A', second_candle: 'N', third_candle: 'N' )
    create(:setup, id: 3, setup: 'Teste', description: 'Teste', quantity_candle: 3, first_candle: 'A', second_candle: 'A', third_candle: 'A' )
  end

  it "busca_setup" do
    setup = Setup.busca_setup(1)
    expect(setup.setup).to eq('Harami de Alta')
    expect(setup.quantity_candle).to eq(2)
  end

  it "identifica_quantidade_candles_do_padrao" do
    ret = Setup.identifica_quantidade_candles_do_padrao(1)
    expect(ret).to eq(2)
  end

  it "carrega_lista_de_candles_do_setup" do
    ret = Setup.carrega_lista_de_candles_do_setup(1)
    expect(ret.count).to eq(2)
    expect(ret[0][0]).to eq('primeiro')
    expect(ret[0][1]).to eq(1)
    expect(ret[1][0]).to eq('segundo')
    expect(ret[1][1]).to eq(2)

    ret = Setup.carrega_lista_de_candles_do_setup(2)
    expect(ret.count).to eq(1)

    ret = Setup.carrega_lista_de_candles_do_setup(3)
    expect(ret.count).to eq(3)
    expect(ret[0][0]).to eq('primeiro')
    expect(ret[0][1]).to eq(1)
    expect(ret[1][0]).to eq('segundo')
    expect(ret[1][1]).to eq(2)
    expect(ret[2][0]).to eq('terceiro')
    expect(ret[2][1]).to eq(3)
  end

  it "descricao_tipo_candle" do
    ret = Setup.descricao_tipo_candle('A')
    expect(ret).to eq('Candle de Alta')

    ret = Setup.descricao_tipo_candle('B')
    expect(ret).to eq('Candle de Baixa')

    ret = Setup.descricao_tipo_candle('N')
    expect(ret).to eq('Qualquer Candle')

    ret = Setup.descricao_tipo_candle('')
    expect(ret).to eq('Qualquer Candle')

  end
end