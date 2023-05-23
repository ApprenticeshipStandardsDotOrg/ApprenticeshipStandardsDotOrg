RSpec.configure do |config|
  config.around(:each, elasticsearch: true) do |example|
    reset_elasticsearch
    example.run
  end

  def reset_elasticsearch
    OccupationStandard.__elasticsearch__.create_index!(force: true)
    OccupationStandard.__elasticsearch__.refresh_index!
  end
end
