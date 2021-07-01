require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require 'opentelemetry/sdk'
require 'opentelemetry/exporter/jaeger'

OpenTelemetry::SDK.configure do |c|
  #c.use_all
  #c.use 'OpenTelemetry::Instrumentation::PG'
#  c.use 'OpenTelemetry::Instrumentation::HttpClient'
  c.use 'OpenTelemetry::Instrumentation::Net::HTTP' # something wrong?
  #c.use 'OpenTelemetry::Instrumentation::HTTP'
  c.use 'OpenTelemetry::Instrumentation::Rack'
  c.use 'OpenTelemetry::Instrumentation::Rails'# something wrong?
  c.add_span_processor(
    OpenTelemetry::SDK::Trace::Export::BatchSpanProcessor.new(
      OpenTelemetry::Exporter::Jaeger::AgentExporter.new(host: 'host.docker.internal', port: 6831)
      # Alternatively, for the collector exporter:
      # exporter: OpenTelemetry::Exporter::Jaeger::CollectorExporter.new(endpoint: 'http://host.docker.internal:14268/api/traces')
    )
  )
  c.service_name = 'toy-app'
  c.service_version = '0.1.0'
end

module Myapp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2
    #use OpenTelemetry::Instrumentation::Rack::Middlewares::TracerMiddleware

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
