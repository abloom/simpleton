require "session"

module Simpleton
  class Worker
    attr_reader :location, :middleware_queue, :configuration

    def initialize(location, middleware_queue, configuration)
      @location = location
      @middleware_queue = middleware_queue
      @configuration = configuration
    end

    def run
      commands = middleware_queue.map { |middleware| middleware.call(configuration) }
      shell = Session.new

      commands.each do |command|
        log_execution(command)

        stdout, stderr = execute(shell, location, command)
        process_results(stdout, stderr)

        exit_if_failed(shell.exit_status)
      end
    end

  private
    def log_execution(command)
      puts formatted_line(location, "<", command)
    end

    def execute(session, location, command)
      session.execute("ssh #{location} '#{command}'", :stdin => StringIO.new)
    end

    def process_results(stdout_string, stderr_string)
      stdout_string.split("\n").each { |line| log_output_line(line) }
      stderr_string.split("\n").each { |line| log_error_line(line) }
    end

    def log_output_line(stdout)
      puts formatted_line("\e[32m#{location}\e[0m", ">", stdout) unless stdout.empty?
    end

    def log_error_line(stderr)
      puts formatted_line("\e[31m#{location}\e[0m", "E", stderr) unless stderr.empty?
    end

    def formatted_line(prefix, indicator, message)
      "[#{prefix}]#{indicator} #{message}"
    end

    def exit_if_failed(exit_status)
      Process.exit(exit_status) unless exit_status.zero?
    end
  end
end
