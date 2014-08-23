class Ability
  include CanCan::Ability

  def initialize(user)
    if user
      if user.fl_admin?
        can :manage, :all
      end
    end
    can :manage, Backtest
    can :manage, Setup
    can :manage, SetupRel
  end
end
