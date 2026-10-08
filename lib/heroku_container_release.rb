require "json"
require "net/http"
require "stringio"
require "uri"
require "zlib"

class HerokuContainerRelease
  def initialize(app:, api_key:, images:, timeout: 3600, poll_interval: 5)
    @app = URI.encode_www_form_component(app)
    @api_key = api_key
    @images = images
    @timeout = timeout
    @poll_interval = poll_interval
  end

  def call
    unless @images.keys.sort == %w[release web worker] && @images.values.all? { |id| /\Asha256:[0-9a-f]{64}\z/.match?(id) }
      raise ArgumentError, "Provide web, worker, and release Docker image IDs"
    end

    previous_release = releases.max_by { |release| release.fetch("version") }
    previous_version = previous_release&.fetch("version") || 0
    request(:patch, "formation", updates: @images.map { |type, image| {type: type, docker_image: image} })

    deadline = monotonic_time + @timeout
    release = nil
    loop do
      raise "Timed out waiting for the Heroku release phase" if monotonic_time >= deadline

      release = if release
        request(:get, "releases/#{release.fetch("id")}")
      else
        releases.select { |candidate| candidate.fetch("version") > previous_version }.min_by { |candidate| candidate.fetch("version") } || previous_release
      end

      if release
        case release.fetch("status")
        when "succeeded"
          return release
        when "failed"
          raise "Heroku release v#{release.fetch("version")} failed; inspect its release phase logs"
        when "pending"
          # Keep staging's release phase as a gate for production.
        else
          raise "Unexpected Heroku release status: #{release.fetch("status")}"
        end
      end
      sleep @poll_interval
    end
  end

  private

  def releases
    request(:get, "releases")
  end

  def monotonic_time
    Process.clock_gettime(Process::CLOCK_MONOTONIC)
  end

  def request(method, path, body = nil)
    uri = URI("https://api.heroku.com/apps/#{@app}/#{path}")
    klass = (method == :patch) ? Net::HTTP::Patch : Net::HTTP::Get
    req = klass.new(uri)
    req["Authorization"] = "Bearer #{@api_key}"
    req["Accept"] = (method == :patch) ? "application/vnd.heroku+json; version=3.docker-releases" : "application/vnd.heroku+json; version=3"
    req["Range"] = "version ..; max=1, order=desc" if path == "releases"
    if body
      req["Content-Type"] = "application/json"
      req.body = JSON.generate(body)
    end
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, open_timeout: 30, read_timeout: 60) { |http| http.request(req) }
    raise "Heroku #{method.upcase} #{path} failed (HTTP #{response.code})" unless response.is_a?(Net::HTTPSuccess)

    response_body = response.body
    # Net::HTTP skips decompression for Content-Range, including Heroku's
    # record pagination. Automatically decoded responses have this header removed.
    if %w[gzip x-gzip].include?(response["Content-Encoding"]&.downcase)
      response_body = Zlib::GzipReader.wrap(StringIO.new(response_body), &:read)
    end
    JSON.parse(response_body)
  end
end
