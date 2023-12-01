module RelatedInstructionsHelper
  def related_instruction_accordion_class(related_instruction)
    if related_instruction.has_details_to_display?
      "accordion"
    end
  end

  def related_instruction_toggle_icon(related_instruction)
    if related_instruction.has_details_to_display?
      "before:content-['+']"
    end
  end

  def related_instruction_hours_display_class(related_instruction)
    if related_instruction.hours.to_i.positive?
      "visible"
    else
      "invisible"
    end
  end
end
