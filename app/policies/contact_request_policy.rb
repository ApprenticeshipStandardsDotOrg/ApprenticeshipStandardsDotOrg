class ContactRequestPolicy < AdminPolicy
  def index?
    admin_or_converter?
  end
end
