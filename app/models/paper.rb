class Paper < ActiveRecord::Base

  validates_presence_of :nr_lote
  validates_presence_of :symbol
  validates_presence_of :description

    def self.busca_papel(id)
      return self.find_by_id(id)
    end

end
