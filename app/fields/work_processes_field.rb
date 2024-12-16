require "administrate/field/base"

class WorkProcessesField < Administrate::Field::HasMany
  def to_s
    data
  end
end
