class OccupationStandardPolicy < AdminPolicy
  attr_reader :user, :occupation_standard

  def initialize(user, occupation_standard)
    @user = user
    @occupation_standard = occupation_standard
  end
end
