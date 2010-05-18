module Simpleton
  class Worker
    attr_reader :location, :middleware_chain, :command_runner, :configuration

    def initialize(location, middleware_chain, command_runner, configuration)
      @location = location
      @middleware_chain = middleware_chain
      @command_runner = command_runner
      @configuration = configuration
    end

    def run
      commands = middleware_chain.map { |middleware| middleware.call(configuration)}

      if commands.all? { |command| command_runner.run(location, command) }
        Process.exit(0)
      else
        Process.exit(1)
      end
    end
  end
end
