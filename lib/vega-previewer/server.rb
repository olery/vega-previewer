module VegaPreviewer
  ##
  # Websocket server for pushing new Vega specs to a client.
  #
  class Server
    ##
    # @param [String] directory
    #
    def initialize(directory)
      @clients   = []
      @mutex     = Mutex.new
      @directory = directory
    end

    ##
    # @param [Hash] env
    # @return [Array]
    #
    def call(env)
      unless websocket?(env)
        return [400, {'Content-Type' => 'text/plain'}, ['Websockets only!']]
      end

      client = Faye::WebSocket.new(env)

      client.on(:open) do |event|
        synchronize do
          @clients << client
        end
      end

      client.on(:close) do |event|
        synchronize { @clients.delete(client) }
      end

      client.on(:message) do |event|
        payload = JSON.load(event.data)
        name    = payload['name']

        if name and valid_file?(name)
          send_file(client, name, parse_file(name))
        end
      end

      return client.rack_response
    end

    ##
    # @param [String] filename
    # @param [Mixed] content
    #
    def publish(filename, content)
      synchronize do
        @clients.each { |client| send_file(client, filename, content) }
      end
    end

    ##
    # @param [Mixed] client
    # @param [String] filename
    # @param [Mixed] content
    #
    def send_file(client, filename, content)
      send(client, :name => filename, :content => content)
    end

    ##
    # @param [Mixed] client
    # @param [Hash] payload
    #
    def send(client, payload)
      client.send(JSON.dump(payload))
    end

    private

    ##
    # @param [Hash] env
    # @return [TrueClass|FalseClass]
    #
    def websocket?(env)
      return Faye::WebSocket.websocket?(env)
    end

    def synchronize
      return @mutex.synchronize { yield }
    end

    ##
    # @param [String] name
    # @return [Mixed]
    #
    def parse_file(name)
      path = File.join(@directory, name)

      return JSON.load(File.read(path))
    end

    ##
    # @param [String] name
    # @return [TrueClass|FalseClass]
    #
    def valid_file?(name)
      path  = File.join(@directory, name)
      match = name =~ /^[^\.]+\.json$/

      return !match.nil? && File.file?(path)
    end
  end # Server
end # VegaPreviewer
