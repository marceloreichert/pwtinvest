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

  it "Existe relacionamento entre candles" do
    ret = Backtest.lista_relacionamentos_entre_candles(1)
    expect(ret.count).to eq 2

    ret = Backtest.lista_relacionamentos_entre_candles(0)
    expect(ret.count).to eq 0
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

    ret = Backtest.atualiza_nr_lancamento_no_extrato(ret)

    expect(ret.count).to eq 6
    expect(ret[0][:lancamento]).to eq 1
    expect(ret[1][:lancamento]).to eq 2
    expect(ret[2][:lancamento]).to eq 3
    expect(ret[3][:lancamento]).to eq 4
    expect(ret[4][:lancamento]).to eq 5
    expect(ret[5][:lancamento]).to eq 6

  end

  it "identifica_valor_ponto_de_entrada" do
    #identifica_valor_ponto_de_entrada(pe1_valor, pe1_acima_abaixo, pe1_ponto_do_candle, pe1_lista_de_candles, candles)
    candles_do_padrao = []
    candles_do_padrao << {:date_quotation => '2000-01-13',
                          :open => 112.5,
                          :close => 106.5,
                          :low => 106,
                          :high => 112.5,
                          :valor_ifr => 0,
                          :valor_media => 0  }
    candles_do_padrao << {:date_quotation => '2000-01-14',
                          :open => 107.5,
                          :close => 108,
                          :low => 106,
                          :high => 110.5,
                          :valor_ifr => 0,
                          :valor_media => 0  }
    candles_do_padrao << {:date_quotation => '2000-01-15',
                          :open => 12.5,
                          :close => 10,
                          :low => 11,
                          :high => 11.5,
                          :valor_ifr => 0,
                          :valor_media => 0  }

    valor_de_entrada = Backtest.identifica_valor_ponto_de_entrada(0.01,'acima','high','2', candles_do_padrao)
    expect(valor_de_entrada).to eq 110.51

    valor_de_entrada = Backtest.identifica_valor_ponto_de_entrada(0.01,'acima','low','2', candles_do_padrao)
    expect(valor_de_entrada).to eq 106.01

    valor_de_entrada = Backtest.identifica_valor_ponto_de_entrada(0.01,'acima','close','2', candles_do_padrao)
    expect(valor_de_entrada).to eq 108.01

    valor_de_entrada = Backtest.identifica_valor_ponto_de_entrada(0.01,'acima','open','2', candles_do_padrao)
    expect(valor_de_entrada).to eq 107.51

    valor_de_entrada = Backtest.identifica_valor_ponto_de_entrada(0.01,'acima','high','1', candles_do_padrao)
    expect(valor_de_entrada).to eq 112.51

    valor_de_entrada = Backtest.identifica_valor_ponto_de_entrada(0.01,'abaixo','high','3', candles_do_padrao)
    expect(valor_de_entrada).to eq 11.49

  end

  it "carrega_lista_ponto_do_candle" do
    #[['da maxima','high'], ['da minima','low'], ['da abertura','open'], ['do fechamento','close']]
    ponto_do_candle = Backtest.carrega_lista_ponto_do_candle
    expect(ponto_do_candle).to be
    expect(ponto_do_candle[0][0]).to eq 'da maxima'
    expect(ponto_do_candle[1][0]).to eq 'da minima'
    expect(ponto_do_candle[2][0]).to eq 'da abertura'
    expect(ponto_do_candle[3][0]).to eq 'do fechamento'
    expect(ponto_do_candle[0][1]).to eq 'high'
    expect(ponto_do_candle[1][1]).to eq 'low'
    expect(ponto_do_candle[2][1]).to eq 'open'
    expect(ponto_do_candle[3][1]).to eq 'close'
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

  it  'find Harami de Alta' do
    ticks = DailyQuotation.all
    expect(ticks.count).to eq 3

    trade  = Backtest.verifica_padrao(  ticks,
                                0,
                                {:id => "1"},
                                1,
                                Date.new(2012,3,11),
                                2000,
                                6000,
                                "ao_atingir",
                                "0.01",
                                "acima",
                                "high",
                                "1",
                                "0.01",
                                "abaixo",
                                "low",
                                "1",
                                "6",
                                "70",
                                "05")
    expect(trade[:id]).to eq 1
    expect(trade[:status]).to eq "ENCONTRADO"

  end

  it  'not find setup' do
    ticks = DailyQuotation.all
    expect(ticks.count).to eq 3

    trade  = Backtest.verifica_padrao(  ticks,
                                0,
                                {:id => "2"},
                                1,
                                Date.new(2012,3,11),
                                2000,
                                6000,
                                "ao_atingir",
                                "0.01",
                                "acima",
                                "high",
                                "1",
                                "0.01",
                                "abaixo",
                                "low",
                                "1",
                                "6",
                                "70",
                                "05")
    expect(trade).to eq nil
  end

  it  'find_setup Harami de Alta with 1 candle after'  do
    ticks = DailyQuotation.all
    expect(ticks.count).to eq 3

    retorno = Backtest.find_setup(ticks, 0, 1, '5')

    expect(retorno[:find]).to eq true
    expect(retorno[:candles_on_setup].count).to eq 2
    expect(retorno[:candles_after_setup].count).to eq 1
  end

  it  'find_setup Harami de Alta without candles after'  do
    ticks = DailyQuotation.find(1,2)
    expect(ticks.count).to eq 2

    retorno = Backtest.find_setup(ticks, 0, 1, '5')

    expect(retorno[:find]).to eq false
    expect(retorno[:candles_on_setup].count).to eq 0
    expect(retorno[:candles_after_setup].count).to eq 0
  end


  it 'valida a relacao entre os candles do padrao Harami de Alta' do
    candles_do_padrao = []
    candles_do_padrao << {:date_quotation => '2000-01-13',
                          :open => 112.5,
                          :close => 106.5,
                          :low => 106,
                          :high => 112.5  }
    candles_do_padrao << {:date_quotation => '2000-01-14',
                          :open => 107.5,
                          :close => 108,
                          :low => 106,
                          :high => 110.5  }

    ret = Backtest.valida_relacao_entre_candles(candles_do_padrao, 1)
    expect(ret).to eq true
  end


  it 'nao valida a relacao entre os candles do padrao Harami de Alta' do
    candles_do_padrao = []
    candles_do_padrao << {:date_quotation => '2000-01-13',
                          :open => 112.5,
                          :close => 106.5,
                          :low => 106,
                          :high => 112.5  }
    candles_do_padrao << {:date_quotation => '2000-01-14',
                          :open => 100.5,
                          :close => 108,
                          :low => 106,
                          :high => 110.5  }

    ret = Backtest.valida_relacao_entre_candles(candles_do_padrao, 1)
    expect(ret).to eq false
  end

end