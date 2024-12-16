require "administrate/field/base"

class WorkProcessesField < Administrate::Field::Base
  def to_s
    data
  end
end
