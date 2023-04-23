class SourceFilePolicy < ApplicationPolicy
  attr_reader :user, :source_file

  def initialize(user, source_file)
    @user = user
    @source_file = source_file
  end

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

  private

  def admin_or_converter?
    %w[admin converter].include?(user.role)
  end
end
