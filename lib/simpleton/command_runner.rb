require 'open3'

module Simpleton
  class CommandRunner
    def self.run(host, command)
      puts "[#{host}]< #{command}"
      i,o,e = ::Open3.popen3("ssh", host, command)

      unless (std_lines = o.readlines).empty?
        puts std_lines.map { |std_line| "[#{host}]> #{std_line}" }.join
      end

      unless (err_lines = e.readlines).empty?
        puts err_lines.map { |error_line| "[#{host}]E #{error_line}" }.join
      end

      true
    end
  end
end