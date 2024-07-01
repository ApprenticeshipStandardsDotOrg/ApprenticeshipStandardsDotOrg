require "administrate/field/base"

class PseudoFileUploadField < Administrate::Field::Base
  def to_s
    data
  end
end
