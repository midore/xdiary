#!/path/to/ruby18
# coding: utf-8

# --------------------
# run.rb
# --------------------

module Xdiary

  class Start
    def initialize
      # $LOAD_PATH.delete(".")
      #
      ### Setting path to 'xdiary-conf' ###
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

