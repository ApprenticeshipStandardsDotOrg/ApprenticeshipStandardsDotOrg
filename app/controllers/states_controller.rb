class StatesController < ApplicationController
  def index
    state_info = State.order(:name).pluck(:name, :id)
    @names_by_letter = state_info.group_by { |state| state[0][0] }
  end
end
