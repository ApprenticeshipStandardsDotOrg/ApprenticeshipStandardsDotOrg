class DocsPolicy < AdminPolicy
  def index?
    admin_or_converter?
  end
end
