require 'test_helper'

context "Simpleton" do
  setup { Simpleton }
  asserts_topic.responds_to :configure
  asserts_topic.responds_to :use
  asserts_topic.responds_to :run

  asserts("that Simpleton::Master is autoloaded") { Simpleton::Master }
  asserts("that Simpleton::Master is autoloaded") { Simpleton::Middleware }
  asserts("that Simpleton::Worker is autoloaded") { Simpleton::Worker }
end

context "Simpleton.run" do
  setup do
    Simpleton.configure { |c| c[:hosts] = ["prod01"] }
    Simpleton.use Proc.new { "foo" }
  end

  asserts "that after a successful run, the master's middleware_queues are empty" do
    stub(Simpleton.master).run { true }

    Simpleton.run
    Simpleton.master.middleware_queues
  end.empty
end
