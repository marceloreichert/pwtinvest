require 'test_helper'

class SetupTest < ActiveSupport::TestCase
  
  test "busca_setup" do
    setup = Setup.busca_setup(1)
    assert setup.setup = 'Harami de Alta', 'O nome do setup deveria ser Harami de Alta'
    assert setup.quantity_candle == 2, 'Deveria ter quantity_candle=2'
  end
  
  test "identifica_quantidade_candles_do_padrao" do
    ret = Setup.identifica_quantidade_candles_do_padrao(1)
    assert ret == 2, 'Deveria ter retornado 2 candles. Retornou ' + ret.to_s
  end
  
  test "carrega_lista_de_candles_do_setup" do
    ret = Setup.carrega_lista_de_candles_do_setup(1)
    assert ret.count == 2, 'Deveria retonar 2, mas retornou ' + ret.count.to_s
    assert ret[0][0] == 'primeiro', 'Deveria retornar <primeiro>' 
    assert ret[0][1] == 1, 'Deveria retornar <1>' 
    assert ret[1][0] == 'segundo', 'Deveria retornar <segundo>' 
    assert ret[1][1] == 2, 'Deveria retornar <2>' 

    ret = Setup.carrega_lista_de_candles_do_setup(2)
    assert ret.count == 1, 'Deveria retonar 1, mas retornou ' + ret.count.to_s

    ret = Setup.carrega_lista_de_candles_do_setup(3)
    assert ret.count == 3, 'Deveria retonar 3, mas retornou ' + ret.count.to_s
    assert ret[0][0] == 'primeiro', 'Deveria retornar <primeiro>' 
    assert ret[0][1] == 1, 'Deveria retornar <1>' 
    assert ret[1][0] == 'segundo', 'Deveria retornar <segundo>' 
    assert ret[1][1] == 2, 'Deveria retornar <2>' 
    assert ret[2][0] == 'terceiro', 'Deveria retornar <terceiro>' 
    assert ret[2][1] == 3, 'Deveria retornar <3>' 

  end
  
  test "descricao_tipo_candle" do
    ret = Setup.descricao_tipo_candle('A')
    assert ret == 'Candle de Alta', 'Deveria retonar a descricao <Candle de Alta>'
    ret = Setup.descricao_tipo_candle('B')
    assert ret == 'Candle de Baixa', 'Deveria retonar a descricao <Candle de Baixa>'
    ret = Setup.descricao_tipo_candle('N')
    assert ret == 'Qualquer Candle', 'Deveria retonar a descricao <Qualquer Candle>'
    ret = Setup.descricao_tipo_candle('')
    assert ret == 'Qualquer Candle', 'Deveria retonar a descricao <Qualquer Candle>'
    
  end
end