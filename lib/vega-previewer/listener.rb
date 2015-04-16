module VegaPreviewer
  ##
  # Watches a directory for any file changes and sends these over to the
  # websocket server.
  #
  class Listener
    ##
    # @param [String] directory
    # @param [VegaPreviewer::Server] server
    #
    def initialize(directory, server)
      @directory = directory
      @server    = server
    end

    def start
      listener = Listen.to(@directory, :only => /\.json$/) do |modified, added|
        (modified + added).each do |file|
          name = File.basename(file)

          @server.publish(name, parse_file(file))
        end
      end

      listener.start
    end

    private

    ##
    # @param [String] file
    # @return [Mixed]
    #
    def parse_file(file)
      return JSON.load(File.read(file))
    end
  end # Listener
end # VegaPreviewer
