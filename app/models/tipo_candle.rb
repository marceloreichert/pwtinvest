class TipoCandle < ActiveRecord::Base
  has_many :user_setups
end
