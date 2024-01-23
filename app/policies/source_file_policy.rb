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

  # Allowing converters to update so they can claim a source file. But we do not
  # currently want them to access the edit page.
  def update?
    admin_or_converter?
  end

  def destroy?
    user.admin?
  end

  def destroy_redacted_source_file?
    user.admin?
  end

  def permitted_attributes
    if user.converter?
      [:status, :assignee_id, :ready_for_redaction]
    else
      [:status, :assignee_id, :metadata, :public_document, :courtesy_notification, :ready_for_redaction]
    end
  end
end
