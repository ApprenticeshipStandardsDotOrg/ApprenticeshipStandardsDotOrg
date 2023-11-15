require "administrate/field/base"

class HasManyAssociatedOccupationStandardsField < Administrate::Field::HasMany
  def to_s
    data
  end
end
