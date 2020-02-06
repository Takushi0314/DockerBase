require ::File.expand_path('../config/environment', __FILE__)

##
# Use the worker killer when Unicorn is being used
if defined?(Unicorn) && Rails.env.production?
  require 'unicorn/worker_killer'

  min_ram = ENV.fetch('OPENPROJECT_UNICORN_RAM2KILL_MIN', 340 * 1 << 20).to_i
  max_ram = ENV.fetch('OPENPROJECT_UNICORN_RAM2KILL_MAX', 400 * 1 << 20).to_i
  min_req = ENV.fetch('OPENPROJECT_UNICORN_REQ2KILL_MIN', 3072).to_i
  max_req = ENV.fetch('OPENPROJECT_UNICORN_REQ2KILL_MAX', 4096).to_i

  # Kill Workers randomly between 340 and 400 MB (per default)
  # or between 3072 and 4096 requests.
  # Our largest installations are starting around 200/230 MB
  use Unicorn::WorkerKiller::Oom, min_ram, max_ram
  use Unicorn::WorkerKiller::MaxRequests, min_req, max_req
end

##
# Returns true if the application should be run under a subdirectory.
def map_subdir?
  # Don't map subdir when using Passenger as passenger takes care of that.
  !defined?(::PhusionPassenger)
end

subdir = map_subdir? && OpenProject::Configuration.rails_relative_url_root.presence

#map (subdir || '/openproject') do
map (subdir || '/openproject') do
  use Rack::Protection::JsonCsrf
  use Rack::Protection::FrameOptions

  run OpenProject::Application
end

