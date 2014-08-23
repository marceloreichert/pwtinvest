class ExtratoController < ApplicationController
  load_and_authorize_resource

  def extrato_financeiro(quote)
    quote.each do |q|

      @extrato = Extrato.new
      @extrato.data = q.data_compra
      @extrato.valor = q.valor_total_entrada
      @extrato.id = q.id
      @extrato.tipo = "C"

    end

  end
  
end
