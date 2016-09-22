class Extrato < ActiveRecord::Base

  def self.extrato_financeiro(quote, saldo_inicial)
    @extrato_financeiro = []

    quote.each do |q|
      if q.fl_validado == "S"
        extrato = Extrato.new
        extrato.data = q.data_1
        extrato.valor = q.valor_1
        extrato.tipo = 'C'
        extrato.id = q.id
        @extrato_financeiro << extrato

        unless q.valor_2.nil?
          extrato = Extrato.new
          extrato.data = q.data_2
          extrato.valor = q.valor_2
          extrato.tipo = 'V'
          extrato.id = q.id
          @extrato_financeiro << extrato
        end 
        
        unless q.valor_3.nil?
          extrato = Extrato.new
          extrato.data = q.data_3
          extrato.valor = q.valor_3
          extrato.tipo = 'V'
          extrato.id = q.id
          @extrato_financeiro << extrato
        end
        
        unless q.valor_4.nil?
          extrato = Extrato.new
          extrato.data = q.data_4
          extrato.valor = q.valor_4
          extrato.tipo = 'V'
          extrato.id = q.id
          @extrato_financeiro << extrato
        end 
        
        unless q.valor_5.nil?
          extrato = Extrato.new
          extrato.data = q.data_5
          extrato.valor = q.valor_5
          extrato.tipo = 'V'
          extrato.id = q.id
          @extrato_financeiro << extrato
        end
      end
    end
    @extrato_financeiro = @extrato_financeiro.sort_by {|a| a.data }
    
    saldo = saldo_inicial.to_f
    @extrato_financeiro.each do |e|
      if e.tipo == "C"
        saldo = saldo - e.valor
      end 
      if e.tipo == "V"
        saldo = saldo + e.valor
      end 
      e.saldo = saldo
    end
    
    return @extrato_financeiro
  end
  
end
