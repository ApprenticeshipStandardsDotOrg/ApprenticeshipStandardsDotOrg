class Imports::DocxPolicy < ImportPolicy
  def show?
    user.admin?
  end

  def update?
    user.admin?
  end
end
