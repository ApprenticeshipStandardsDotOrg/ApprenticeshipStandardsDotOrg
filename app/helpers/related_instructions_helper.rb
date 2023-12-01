module RelatedInstructionsHelper
  def related_instruction_hours_display_class(related_instruction)
    if related_instruction.hours.to_i.positive?
      "visible"
    else
      "invisible"
    end
  end
end
