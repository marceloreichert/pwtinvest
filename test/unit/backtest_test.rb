require 'test_helper'

class BacktestTest < ActiveSupport::TestCase
  test "Existe relacionamento entre candles" do
    ret = Backtest.lista_relacionamentos_entre_candles(1)
    assert ret.count > 0, 'Nao retornou linhas de relacionamento entre candles.'

    ret = Backtest.lista_relacionamentos_entre_candles(0)
    assert ret.count == 0, 'Nao retornou linhas de relacionamento entre candles.'
  end

  test "insere_lancamentos_no_extrato" do
    #insere_lancamentos_no_extrato(data, valor, tipo, id, saldo)
    ret = Backtest.insere_lancamentos_no_extrato(Time.now, 0, 'I', 0, 0, 0, 0)
    assert !ret.nil?, 'Deveria inserir dados no extrato.'

    ret = Backtest.insere_lancamentos_no_extrato(Time.now, 0, 'I', 0, 0, 0, 0)
    assert ret.count == 8, 'Deveriam ter 8 hashs'

    ret = []
    ret << Backtest.insere_lancamentos_no_extrato(Time.now, 0, 'I', 0, 0, 0, 0)
    assert ret.count == 1, 'Deveria ter 1 registro. '
    ret << Backtest.insere_lancamentos_no_extrato(Time.now, 0, 'C', 0, 0, 0, 0)
    assert ret.count == 2, 'Deveriam ter 2 registros.'
    ret << Backtest.insere_lancamentos_no_extrato(Time.now, 0, 'V', 0, 0, 0, 0)
    assert ret.count == 3, 'Deveriam ter 3 registros.'
  end

  test "atualiza_nr_lancamento_no_extrato" do
    ret = []
    ret   << Backtest.insere_lancamentos_no_extrato(Time.now, 0, 'V', 0, 0, 0, 0)
    ret   << Backtest.insere_lancamentos_no_extrato(Time.now, 0, 'V', 0, 0, 0, 0)
    ret   << Backtest.insere_lancamentos_no_extrato(Time.now, 0, 'V', 0, 0, 0, 0)
    ret   << Backtest.insere_lancamentos_no_extrato(Time.now, 0, 'V', 0, 0, 0, 0)
    ret   << Backtest.insere_lancamentos_no_extrato(Time.now, 0, 'V', 0, 0, 0, 0)
    ret   << Backtest.insere_lancamentos_no_extrato(Time.now, 0, 'V', 0, 0, 0, 0)

    ret = Backtest.atualiza_nr_lancamento_no_extrato(ret)

    assert  ret.count == 6, 'Total de linhas deveria ser ' << ret.count.to_s
    assert  ret[0][:lancamento] == 1, 'Numero do lancamento deveria ser 1.'
    assert  ret[1][:lancamento] == 2, 'Numero do lancamento deveria ser 2.'
    assert  ret[2][:lancamento] == 3, 'Numero do lancamento deveria ser 3.'
    assert  ret[3][:lancamento] == 4, 'Numero do lancamento deveria ser 4.'
    assert  ret[4][:lancamento] == 5, 'Numero do lancamento deveria ser 5.'
    assert  ret[5][:lancamento] == 6, 'Numero do lancamento deveria ser 6.'

  end

  test "encontrar_padroes_de_candles_do_setup" do
    #encontrar_padroes_de_candles_do_setup(cotacoes, indice, setup_id, quantidade_maxima_candles_do_trade)
    assert  true
  end

  test "valida_media_movel" do
    assert  true
  end

  test "valida_ifr" do
    assert  true
  end

  test "valida_relacao_entre_candles" do
    assert  true
  end

  test "valida_padrao" do
    assert  true
  end

  test "verifica_padrao" do
    assert  true
  end

  test "calcula_totais" do
    assert  true
  end

  test "calcula_ifr" do
    assert  true
  end

  test "calcula_media_movel_exponencial" do
    assert  true
  end

  test "calcula_media_movel_simples" do
    assert  true
  end

  test "gera_xml_do_grafico" do
    assert  true
  end

  test "identifica_valor_ponto_de_entrada" do
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
    assert valor_de_entrada == 110.51, 'O ponto de entrada deveria ser 110.51 e retornou ' << valor_de_entrada.to_s

    valor_de_entrada = Backtest.identifica_valor_ponto_de_entrada(0.01,'acima','low','2', candles_do_padrao)
    assert valor_de_entrada == 106.01, 'O ponto de entrada deveria ser 106.01 e retornou ' << valor_de_entrada.to_s

    valor_de_entrada = Backtest.identifica_valor_ponto_de_entrada(0.01,'acima','close','2', candles_do_padrao)
    assert valor_de_entrada == 108.01, 'O ponto de entrada deveria ser 108.01 e retornou ' << valor_de_entrada.to_s

    valor_de_entrada = Backtest.identifica_valor_ponto_de_entrada(0.01,'acima','open','2', candles_do_padrao)
    assert valor_de_entrada == 107.51, 'O ponto de entrada deveria ser 107.51 e retornou ' << valor_de_entrada.to_s

    valor_de_entrada = Backtest.identifica_valor_ponto_de_entrada(0.01,'acima','high','1', candles_do_padrao)
    assert valor_de_entrada == 112.51, 'O ponto de entrada deveria ser 112.51 e retornou ' << valor_de_entrada.to_s

    valor_de_entrada = Backtest.identifica_valor_ponto_de_entrada(0.01,'abaixo','high','3', candles_do_padrao)
    assert valor_de_entrada == 11.49, 'O ponto de entrada deveria ser 11.49 e retornou ' << valor_de_entrada.to_s

  end

  test "carrega_lista_ponto_do_candle" do
    #[['da maxima','high'], ['da minima','low'], ['da abertura','open'], ['do fechamento','close']]
    ponto_do_candle = Backtest.carrega_lista_ponto_do_candle
    assert  !ponto_do_candle.empty?, 'Lista esta vazia.'
    assert  ponto_do_candle[0][0] == 'da maxima', 'Deveria retornar <da maxima>'
    assert  ponto_do_candle[1][0] == 'da minima', 'Deveria retornar <da minima>'
    assert  ponto_do_candle[2][0] == 'da abertura', 'Deveria retornar <da abertura>'
    assert  ponto_do_candle[3][0] == 'do fechamento', 'Deveria retornar <do fechamento>'
    assert  ponto_do_candle[0][1] == 'high', 'Deveria retornar <high>'
    assert  ponto_do_candle[1][1] == 'low', 'Deveria retornar <low>'
    assert  ponto_do_candle[2][1] == 'open', 'Deveria retornar <open>'
    assert  ponto_do_candle[3][1] == 'close', 'Deveria retornar <close>'
  end

  test "carrega_lista_acima_abaixo" do
    ret = Backtest.carrega_lista_acima_abaixo
    assert  ret[0][0] ==  "acima"
    assert  ret[0][1] ==  "acima"
    assert  ret[1][0] ==  "abaixo"
    assert  ret[1][1] ==  "abaixo"
  end

  test "carrega_lista_ponto_de_entrada" do
    ret = Backtest.carrega_lista_ponto_de_entrada
    assert  ret[0][0] ==  "Ao atingir"
    assert  ret[0][1] ==  "ao_atingir"
    assert  ret[1][0] ==  "Ao fechar"
    assert  ret[1][1] ==  "ao_fechar"


  end

  test "identifica_dados_do_proximo_candle_apos_padrao" do
    assert  true
  end

  test "identifica_valor_ponto_de_saida" do
    ret = Backtest.identifica_valor_ponto_de_saida(10, 10)
    assert  ret == 11, 'Retornou ' << ret.to_s << '. Correto = 11'
    ret = Backtest.identifica_valor_ponto_de_saida(20, 2)
    assert  ret == 20.4, 'Retornou ' << ret.to_s << '. Correto = 20.40'
  end

  test "identifica_valor_ponto_de_stop" do
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
    assert ret == 22.01, 'Retornou ' << ret.to_s << ', correto seria 22.01'
    ret = Backtest.identifica_valor_ponto_de_stop(0.01, 'acima', 'maxima', '1', candles_do_padrao)
    assert ret == 23.01, 'Retornou ' << ret.to_s << ', correto seria 23.01'
    ret = Backtest.identifica_valor_ponto_de_stop(0.01, 'abaixo', 'minima', '1', candles_do_padrao)
    assert ret == 7.99, 'Retornou ' << ret.to_s << ', correto seria 7.99'
  end

end
