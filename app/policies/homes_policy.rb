class HomesPolicy < ApplicationPolicy
  def initialize(user, page)
    @user = user
    @page = page
  end

  def index?
    true
  end
end
