class WorkProcessBlueprint < BaseBlueprint
  fields :title, :default_hours, :minimum_hours, :maximum_hours, :competencies_count

  association :competencies, blueprint: CompetencyBlueprint
end
