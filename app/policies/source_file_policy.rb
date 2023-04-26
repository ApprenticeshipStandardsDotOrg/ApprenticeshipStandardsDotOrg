class SourceFilePolicy < ApplicationPolicy
  def index?
    admin_or_converter?
  end

  def show?
    admin_or_converter?
  end

  def edit?
    user.admin?
  end

  def update?
    edit?
  end

  def destroy?
    user.admin?
  end
end
