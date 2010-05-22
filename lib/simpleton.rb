module Simpleton
  class Error < ::RuntimeError; end

  autoload :Master, "simpleton/master"
  autoload :Middleware, "simpleton/middleware"
  autoload :Worker, "simpleton/worker"

  def self.configure(*args, &block)
    master.configure(*args, &block)
  end

  def self.use(*args)
    master.use(*args)
  end

  def self.run(*args)
    master.run(*args)
    master.middleware_queues.clear
  end

  def self.master
    Thread.current[:simpleton_master] ||= Master.new
  end
end
