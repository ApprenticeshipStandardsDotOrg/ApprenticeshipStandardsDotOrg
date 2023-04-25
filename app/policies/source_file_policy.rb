class SourceFilePolicy < ApplicationPolicy
  def index?
    admin_or_converter?
  end

  def show?
    index?
  end

  def create?
    user.admin?
  end

  def new?
    index?
  end

  def update?
    user.admin?
  end

  def edit?
    user.admin?
  end

  def destroy?
    user.admin?
  end
end
