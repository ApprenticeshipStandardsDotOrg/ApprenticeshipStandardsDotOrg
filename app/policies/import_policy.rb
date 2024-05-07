class ImportPolicy < ApplicationPolicy
  def index?
    admin_or_converter?
  end

  def show?
    admin_or_converter?
  end

  def new?
    false
  end

  def create?
    false
  end

  def edit?
    false
  end

  def update?
    edit?
  end

  def destroy?
    false
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.all
    end

    private

    attr_reader :user, :scope
  end
end
