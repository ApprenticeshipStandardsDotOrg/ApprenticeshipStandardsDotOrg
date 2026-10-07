module RspecShards
  def self.partition(files, count:, runtimes: {})
    raise ArgumentError, "Shard count must be positive" unless count.positive?

    groups = Array.new(count) { [] }
    totals = Array.new(count, 0.0)
    files.sort_by { |file| [-runtimes.fetch(file, 1.0), file] }.each do |file|
      shard = totals.each_index.min_by { |index| totals[index] }
      groups[shard] << file
      totals[shard] += runtimes.fetch(file, 1.0)
    end
    groups.map(&:sort)
  end
end
