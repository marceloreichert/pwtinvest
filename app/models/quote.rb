class Quote < ActiveRecord::Base

  cattr_reader :per_page
  @@per_page = 10

  def self.qtd_padroes_encontrados(quotes)
    quantidade = 0
    quotes.each do |q|
        quantidade = quantidade + 1
    end 
    return quantidade
  end


  def self.qtd_padroes_vencedores(quotes)
    quantidade = 0
    quotes.each do |q|
      if q.valor_total_saida.to_f > q.valor_total_entrada.to_f
        quantidade = quantidade + 1
      end
    end 
    return quantidade
  end
  
  
  def self.qtd_padroes_perdedores(quotes)
    quantidade = 0
    quotes.each do |q|
      if q.valor_total_entrada.to_f > q.valor_total_saida.to_f
        quantidade = quantidade + 1
      end
    end 
    return quantidade
  end

  def self.qtd_padroes_perdedores_sequencia(quotes)
    quantidade = 0
    maximo = 0
    quotes.each do |q|
      if q.valor_total_entrada.to_f > q.valor_total_saida.to_f
        quantidade = quantidade + 1
      else
        quantidade = 0
      end
      if quantidade > maximo
        maximo = quantidade
      end
    end 
    return maximo
  end
  
  def self.qtd_padroes_validados(quotes)
    quantidade = 0
    quotes.each do |q|
      if q.fl_validado == "S"
        quantidade = quantidade + 1
      end 
    end 
    return quantidade
  end
  
  
  def self.setup_perdedores(quotes)
    quantidade = 0
    quotes.each do |q|
      if q.fl_estopados = "S"
        quantidade = quantidade + 1
      end 
    end 
    return quantidade
  end
  
  
  def self.verifica_importacao(paper)
    
    ver_cotacoes = self.find_all_by_papel_and_data(Paper.busca_papel(paper).symbol, Date.today())
    
    if ver_cotacoes.empty?
      return true
    else
      return true
    end     
  end
  
  
  
end
