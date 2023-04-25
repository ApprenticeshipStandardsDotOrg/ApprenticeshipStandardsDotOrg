class DataImportPolicy < ApplicationPolicy
  attr_reader :user, :data_import

  def initialize(user, data_import)
    @user = user
    @data_import = data_import
  end

  def show?
    admin_or_converter?
  end

  def create?
    show?
  end

  def new?
    show?
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
