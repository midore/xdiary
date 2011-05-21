#!/path/to/ruby18
# coding: utf-8

# --------------------
# run.rb
# --------------------

module Xdiary
  class Start
    def initialize
      $LOAD_PATH.delete(".")
      dir = File.dirname(File.dirname(File.expand_path($PROGRAM_NAME)))
      $LOAD_PATH.push(File.join(dir, 'lib'))

      # [Default setting]
      conf_path = File.join(dir, 'xdiary-conf')
      # It's means setting like '/path/to/xdiary/xdiary-conf'
      #
      # [Customize setting]
      # conf_path = '/path/to/yours/xdiary-conf'
      #

      (print "Error: not found xdiary-conf\n"; exit) unless File.exist?(conf_path)
      load conf_path, wrap=true
    end

    def run
      require 'xdiary'
      err, arg_h = CheckStart.new(ARGV).base
      exit if err == 'help'
      (print "#{err}\n"; exit) if err
      Main.new(arg_h)
    end
  end
end

Xdiary::Start.new.run
