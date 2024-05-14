class Imports::DocxPolicy < AdminPolicy
  def show?
    user.admin?
  end

  def update?
    user.admin?
  end
end
