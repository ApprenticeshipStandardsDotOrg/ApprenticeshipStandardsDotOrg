require "administrate/field/base"

class GenericRecordField < Administrate::Field::Base
  def to_s
    data
  end
end
