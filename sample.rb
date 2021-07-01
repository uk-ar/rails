require 'opentelemetry/sdk'
require 'opentelemetry/exporter/jaeger'

# Configure the sdk with custom export
OpenTelemetry::SDK.configure do |c|
  c.add_span_processor(
    OpenTelemetry::SDK::Trace::Export::BatchSpanProcessor.new(
      OpenTelemetry::Exporter::Jaeger::AgentExporter.new(host: 'host.docker.internal', port: 6831)
      # Alternatively, for the collector exporter:
      # exporter: OpenTelemetry::Exporter::Jaeger::CollectorExporter.new(endpoint: 'http://host.docker.internal:14268/api/traces')
    )
  )
  c.service_name = 'jaeger-example'
  c.service_version = '0.6.0'
end

# To start a trace you need to get a Tracer from the TracerProvider
tracer = OpenTelemetry.tracer_provider.tracer('my_app_or_gem', '0.1.0')

# create a span
tracer.in_span('foo') do |span|
  # set an attribute
  span.set_attribute('platform', 'osx')
  # add an event
  span.add_event('event in bar')
  # create bar as child of foo
  tracer.in_span('bar') do |child_span|
    # inspect the span
    pp child_span
  end
end
