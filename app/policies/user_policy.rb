class UserPolicy < AdminPolicy
  def invite?
    user.admin?
  end
end
