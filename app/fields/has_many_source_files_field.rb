require "administrate/field/base"

class HasManySourceFilesField < Administrate::Field::Base
  def to_s
    data
  end
end
