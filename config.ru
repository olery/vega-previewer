require File.expand_path('../lib/vega-previewer', __FILE__)

directory = File.expand_path('../vega', __FILE__)
server    = VegaPreviewer::Server.new(directory)
listener  = VegaPreviewer::Listener.new(directory, server)

listener.start

run server
