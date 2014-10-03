require 'rails_helper'

describe Backtest, :type => :model do

  before(:each) do
    create(:setup, id: 1, setup: 'Harami de Alta', description: 'Harami de Alta', quantity_candle: 2, first_candle: 'B', second_candle: 'A', third_candle: 'N')
    create(:setup, id: 2, setup: 'Martelo de Alta', description: 'Martelo de Alta', quantity_candle: 1, first_candle: 'A', second_candle: 'N', third_candle: 'N' )
    create(:setup, id: 3, setup: 'Teste', description: 'Teste', quantity_candle: 3, first_candle: 'A', second_candle: 'A', third_candle: 'A' )

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
  end

  it "insert_list" do
    #insert_list(data, valor, tipo, id, saldo)
    ret = Backtest.insert_list(Time.now, 0, 'I', 0, 0, 0, 0)
    expect(ret).to be

    ret = Backtest.insert_list(Time.now, 0, 'I', 0, 0, 0, 0)
    expect(ret.count).to eq 8

    ret = []
    ret << Backtest.insert_list(Time.now, 0, 'I', 0, 0, 0, 0)
    expect(ret.count).to eq 1
    ret << Backtest.insert_list(Time.now, 0, 'C', 0, 0, 0, 0)
    expect(ret.count).to eq 2
    ret << Backtest.insert_list(Time.now, 0, 'V', 0, 0, 0, 0)
    expect(ret.count).to eq 3
  end

  it "atualiza_nr_lancamento_no_extrato" do
    ret = []
    ret   << Backtest.insert_list(Time.now, 0, 'V', 0, 0, 0, 0)
    ret   << Backtest.insert_list(Time.now, 0, 'V', 0, 0, 0, 0)
    ret   << Backtest.insert_list(Time.now, 0, 'V', 0, 0, 0, 0)
    ret   << Backtest.insert_list(Time.now, 0, 'V', 0, 0, 0, 0)
    ret   << Backtest.insert_list(Time.now, 0, 'V', 0, 0, 0, 0)
    ret   << Backtest.insert_list(Time.now, 0, 'V', 0, 0, 0, 0)

    ret = Backtest.set_counter(ret)

    expect(ret.count).to eq 6
    expect(ret[0][:lancamento]).to eq 1
    expect(ret[1][:lancamento]).to eq 2
    expect(ret[2][:lancamento]).to eq 3
    expect(ret[3][:lancamento]).to eq 4
    expect(ret[4][:lancamento]).to eq 5
    expect(ret[5][:lancamento]).to eq 6

  end




  it  "carrega_lista_acima_abaixo" do
    ret = Backtest.carrega_lista_acima_abaixo
    expect(ret[0][0]).to eq "acima"
    expect(ret[0][1]).to eq "acima"
    expect(ret[1][1]).to eq "abaixo"
    expect(ret[1][1]).to eq "abaixo"
  end

  it "carrega_lista_ponto_de_entrada" do
    ret = Backtest.carrega_lista_ponto_de_entrada
    expect(ret[0][0]).to eq "Ao atingir"
    expect(ret[0][1]).to eq "ao_atingir"
    expect(ret[1][0]).to eq "Ao fechar"
    expect(ret[1][1]).to eq "ao_fechar"
  end

  it "identifica_valor_ponto_de_saida" do
    ret = Backtest.identifica_valor_ponto_de_saida(10, 10)
    expect(ret).to eq 11
    ret = Backtest.identifica_valor_ponto_de_saida(20, 2)
    expect(ret).to eq 20.4
  end

  it "identifica_valor_ponto_de_stop" do
  #  def identifica_valor_ponto_de_stop(pstop1, pstop2, pstop3, pstop4, candles_do_padrao)
    candles_do_padrao = []
    candles_do_padrao << {:date_quotation => Date.new(2012,3,11),
                          :open => 20,
                          :close => 10,
                          :low => 8,
                          :high => 23,
                          :valor_ifr => 0,
                          :valor_media => 0
                          }
    candles_do_padrao << {:date_quotation => Date.new(2012,3,12),
                          :open => 12,
                          :close => 18,
                          :low => 8,
                          :high => 22,
                          :valor_ifr => 0,
                          :valor_media => 0
                          }

    ret = Backtest.identifica_valor_ponto_de_stop(0.01, 'acima', 'maxima', '2', candles_do_padrao)
    expect(ret).to eq 22.01
    ret = Backtest.identifica_valor_ponto_de_stop(0.01, 'acima', 'maxima', '1', candles_do_padrao)
    expect(ret).to eq 23.01
    ret = Backtest.identifica_valor_ponto_de_stop(0.01, 'abaixo', 'minima', '1', candles_do_padrao)
    expect(ret).to eq 7.99
  end

  it 'valida_media_movel - nao deve validar' do
    candles_do_padrao = []
    candles_do_padrao << {:date_quotation => Date.new(2012,3,11),
                          :open => 20,
                          :close => 10,
                          :low => 8,
                          :high => 23,
                          :valor_ifr => 0,
                          :valor_media => 100
                          }
    candles_do_padrao << {:date_quotation => Date.new(2012,3,12),
                          :open => 12,
                          :close => 18,
                          :low => 8,
                          :high => 22,
                          :valor_ifr => 0,
                          :valor_media => 100
                          }
    ret = Backtest.valida_media_movel(candles_do_padrao, setup = {id: 1}, false, 'acima')
    expect(ret[:encontrei]).to eq true
    expect(ret[:historico]).to eq ''

    ret = Backtest.valida_media_movel(candles_do_padrao, setup = {id: 1}, false, 'abaixo')
    expect(ret[:encontrei]).to eq true
    expect(ret[:historico]).to eq ''

    ret = Backtest.valida_media_movel(candles_do_padrao, setup = {id: 1}, false, 'sobre')
    expect(ret[:encontrei]).to eq true
    expect(ret[:historico]).to eq ''

  end

  it 'valida_media_movel quando media for zero' do
    candles_do_padrao = []
    candles_do_padrao << {:date_quotation => Date.new(2012,3,11),
                          :open => 20,
                          :close => 10,
                          :low => 8,
                          :high => 23,
                          :valor_ifr => 0,
                          :valor_media => 0
                          }
    candles_do_padrao << {:date_quotation => Date.new(2012,3,12),
                          :open => 12,
                          :close => 18,
                          :low => 8,
                          :high => 22,
                          :valor_ifr => 0,
                          :valor_media => 0
                          }
    ret = Backtest.valida_media_movel(candles_do_padrao, setup = {id: 1}, true, 'acima')
    expect(ret[:encontrei]).to eq true
    expect(ret[:historico]).to eq ''

    ret = Backtest.valida_media_movel(candles_do_padrao, setup = {id: 1}, true, 'abaixo')
    expect(ret[:encontrei]).to eq true
    expect(ret[:historico]).to eq ''

    ret = Backtest.valida_media_movel(candles_do_padrao, setup = {id: 1}, true, 'sobre')
    expect(ret[:encontrei]).to eq true
    expect(ret[:historico]).to eq ''

  end


  it 'valida_media_movel - quando media for acima do padrao' do
    candles_do_padrao = []
    candles_do_padrao << {:date_quotation => Date.new(2012,3,11),
                          :open => 20,
                          :close => 10,
                          :low => 8,
                          :high => 23,
                          :valor_ifr => 0,
                          :valor_media => 100
                          }
    candles_do_padrao << {:date_quotation => Date.new(2012,3,12),
                          :open => 12,
                          :close => 18,
                          :low => 8,
                          :high => 22,
                          :valor_ifr => 0,
                          :valor_media => 100
                          }
    ret = Backtest.valida_media_movel(candles_do_padrao, setup = {id: 1}, true, 'acima')
    expect(ret[:encontrei]).to eq false
    expect(ret[:historico]).not_to eq ''

    ret = Backtest.valida_media_movel(candles_do_padrao, setup = {id: 1}, true, 'abaixo')
    expect(ret[:encontrei]).to eq true
    expect(ret[:historico]).to eq ''

    ret = Backtest.valida_media_movel(candles_do_padrao, setup = {id: 1}, true, 'sobre')
    expect(ret[:encontrei]).to eq false
    expect(ret[:historico]).not_to eq ''

  end

  it 'valida_media_movel - quando media for abaixo do padrao' do
    candles_do_padrao = []
    candles_do_padrao << {:date_quotation => Date.new(2012,3,11),
                          :open => 20,
                          :close => 10,
                          :low => 8,
                          :high => 23,
                          :valor_ifr => 0,
                          :valor_media => 1
                          }
    candles_do_padrao << {:date_quotation => Date.new(2012,3,12),
                          :open => 12,
                          :close => 18,
                          :low => 8,
                          :high => 22,
                          :valor_ifr => 0,
                          :valor_media => 1
                          }
    ret = Backtest.valida_media_movel(candles_do_padrao, setup = {id: 1}, true, 'acima')
    expect(ret[:encontrei]).to eq true
    expect(ret[:historico]).to eq ''

    ret = Backtest.valida_media_movel(candles_do_padrao, setup = {id: 1}, true, 'abaixo')
    expect(ret[:encontrei]).to eq false
    expect(ret[:historico]).not_to eq ''

    ret = Backtest.valida_media_movel(candles_do_padrao, setup = {id: 1}, true, 'sobre')
    expect(ret[:encontrei]).to eq false
    expect(ret[:historico]).not_to eq ''

  end


  it 'valida_media_movel - quando media for sobre do padrao' do
    candles_do_padrao = []
    candles_do_padrao << {:date_quotation => Date.new(2012,3,11),
                          :open => 20,
                          :close => 10,
                          :low => 8,
                          :high => 23,
                          :valor_ifr => 0,
                          :valor_media => 15
                          }
    candles_do_padrao << {:date_quotation => Date.new(2012,3,12),
                          :open => 12,
                          :close => 18,
                          :low => 8,
                          :high => 22,
                          :valor_ifr => 0,
                          :valor_media => 15
                          }
    ret = Backtest.valida_media_movel(candles_do_padrao, setup = {id: 1}, true, 'acima')
    expect(ret[:encontrei]).to eq false
    expect(ret[:historico]).not_to eq ''

    ret = Backtest.valida_media_movel(candles_do_padrao, setup = {id: 1}, true, 'abaixo')
    expect(ret[:encontrei]).to eq false
    expect(ret[:historico]).not_to eq ''

    ret = Backtest.valida_media_movel(candles_do_padrao, setup = {id: 1}, true, 'sobre')
    expect(ret[:encontrei]).to eq true
    expect(ret[:historico]).to eq ''

  end

end