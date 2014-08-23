require "spec_helper"

def create_paper(attributes={})
  Paper.create({  :symbol => 'PETR4.SA',
                  :description => 'Petrobras',
                  :nr_lote => 100 }.update(attributes))
end
