class ImportPolicy < ApplicationPolicy
  def index?
    Flipper.enabled?(:show_imports_in_administrate) && admin_or_converter?
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
    user.admin?
  end

  # Allowing converters to update so they can claim an import. But we do not
  # currently want them to access the edit page.
  def update?
    admin_or_converter?
  end

  def destroy?
    false
  end

  def permitted_attributes
    if user.converter?
      [:status, :assignee_id, :ready_for_redaction]
    else
      [:status, :assignee_id, :metadata, :public_document, :courtesy_notification, :ready_for_redaction]
    end
  end
end
