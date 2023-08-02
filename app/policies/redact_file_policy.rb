class RedactFilePolicy < ApplicationPolicy
  def new?
    admin_or_converter?
  end
end
