module PagesHelper
  def washington_state
    State.find_by(name: "Washington")
  end

  def new_york_state
    State.find_by(name: "New York")
  end

  def california_state
    State.find_by(name: "California")
  end

  def oregon_state
    State.find_by(name: "Oregon")
  end

  def standards_by_state_count(state)
    OccupationStandard.by_state_id(state.id).count
  end
end
