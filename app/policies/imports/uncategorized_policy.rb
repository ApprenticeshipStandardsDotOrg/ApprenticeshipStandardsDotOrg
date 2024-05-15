class Imports::UncategorizedPolicy < ImportPolicy
  def show?
    user.admin?
  end

  def update?
    user.admin?
  end
end
