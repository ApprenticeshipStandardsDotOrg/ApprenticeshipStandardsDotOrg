class DataImportPolicy < ApplicationPolicy
  attr_reader :user, :data_import

  def initialize(user, data_import)
    @user = user
    @data_import = data_import
  end
end
