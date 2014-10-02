class SetupRel < ActiveRecord::Base

  belongs_to :setups

  def self.load(id_do_setup)
    return SetupRel.where('setup_id = ?', id_do_setup)
  end

end
