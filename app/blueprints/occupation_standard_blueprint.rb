class OccupationStandardBlueprint < BaseBlueprint
  association :work_processes, blueprint: WorkProcessBlueprint
end
