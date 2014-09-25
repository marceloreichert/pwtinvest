class Setup < ActiveRecord::Base
  has_many :setup_rels, :dependent => :delete_all

  attr_accessible :id, :setup, :quantity_candle, :description, :first_candle, :second_candle, :third_candle, :first_candle_type, :second_candle_type, :third_candle_type

  validates_presence_of :setup
  validates_presence_of :description
  validates_presence_of :first_candle
  validates_presence_of :second_candle
  validates_presence_of :third_candle

  cattr_reader :per_page
  @@per_page = 10

  def self.busca_setup(id_do_setup)
    return Setup.find(id_do_setup)
  end

  def self.identifica_quantidade_candles_do_padrao(id_do_setup)
    Setup.busca_setup(id_do_setup).quantity_candle
  end

  def self.carrega_lista_de_candles_do_setup(id_do_setup)
    quantidade_candles_do_padrao = Setup.identifica_quantidade_candles_do_padrao(id_do_setup)

    if quantidade_candles_do_padrao.nil?
      lista_de_candles = [['primeiro',1]]
    elsif quantidade_candles_do_padrao == 1
      lista_de_candles = [['primeiro',1]]
    elsif quantidade_candles_do_padrao == 2
      lista_de_candles = [['primeiro',1],['segundo',2]]
    elsif quantidade_candles_do_padrao == 3
      lista_de_candles = [['primeiro',1],['segundo',2],['terceiro',3]]
    else
      lista_de_candles = [['primeiro',1]]
    end
    return lista_de_candles
  end

  def self.descricao_tipo_candle(tipo_candle)
    if tipo_candle == 'A'
      descricao = 'Candle de Alta'
    elsif tipo_candle == 'B'
      descricao = 'Candle de Baixa'
    else
      descricao = 'Qualquer Candle'
    end
  end

  def self.gera_xml_do_grafico(setup_id, quantidade_candles)
    data_inicial = Date.new(2000, 1, 1)
    data_final = Date.new(2020, 10, 15)

    cotacoes = DailyQuotation.where("paper = ? AND date_quotation between ? AND ?", 'PETR4.SA', data_inicial, data_final).order("date_quotation DESC")
    indice = 0
    str_xml = nil

    cotacoes.each do |cot|
      retorno = VerifySetup.find(cotacoes, indice, setup_id, 4)

      if retorno[:encontrei]
        if VerifySetup.validate_relation(retorno[:candles_do_padrao], setup_id)
          str_xml = Backtest.gera_xml_do_grafico(retorno, 'Exemplo', quantidade_candles)
          return str_xml
        end
      end
      indice = indice + 1
    end
  end
end
