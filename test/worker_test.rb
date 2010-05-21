require 'test_helper'

context "Simpleton::Worker.new" do
  location = "user@host"
  middleware_queue = [ Proc.new {"echo 123"} ]
  configuration = { :a => :b }

  context "with arguments (#{location}, #{middleware_queue.inspect}, #{configuration})" do
    setup { Simpleton::Worker.new(location, middleware_queue, configuration) }

    asserts(:location).equals(location)
    asserts(:middleware_queue).equals(middleware_queue)
    asserts(:configuration).equals(configuration)
  end
end

context "Simpleton::Worker#run" do
  location = "user@host"
  middleware_queue = [ Proc.new {"echo 123"}, Proc.new {"echo `date`"} ]
  configuration = { :a => :b }
  setup { Simpleton::Worker.new(location, middleware_queue, configuration) }

  should "call each middleware in the queue with the worker's configuration" do
    stub(topic).log_execution
    stub(topic).execute { ["", ""] }
    stub(topic).exit_if_failed

    middleware_queue.each do |middleware|
      mock.proxy(middleware).call(configuration)
    end

    topic.run
  end

  should "execute the result of calling each middleware at the worker's location" do
    stub(topic).log_execution
    stub(topic).exit_if_failed

    middleware_queue.each do |middleware|
      mock(topic).execute(anything, location, middleware.call) { ["", ""] }
    end

    topic.run
  end

  should "exit with the status of the first command that fails" do
    stub(topic).log_execution
    stub(topic).execute { ["", ""] }
    status = Time.now.to_i
    stub.instance_of(Session::Sh).exit_status { status }

    mock(Process).exit(status).at_least(1)

    topic.run
  end

  should "log each command executed" do
    stub(topic).execute { ["", ""] }
    stub(topic).exit_if_failed

    middleware_queue.each { |middleware| mock(topic).log_execution(middleware.call) }

    topic.run
  end

  should "log each output line of the command executed" do
    stub(topic).log_execution
    stub(topic).exit_if_failed { true }
    stdout_lines = ["stdout line 1", "stdout line 2"]
    stderr_lines = ["stderr line 1", "stderr line 2"]
    stub(topic).execute { [stdout_lines.join("\n"), stderr_lines.join("\n")] }

    mock(topic).log_output_line(stdout_lines.first).times(middleware_queue.length)
    mock(topic).log_output_line(stdout_lines.last).times(middleware_queue.length)
    mock(topic).log_error_line(stderr_lines.first).times(middleware_queue.length)
    mock(topic).log_error_line(stderr_lines.last).times(middleware_queue.length)

    topic.run
  end
end
