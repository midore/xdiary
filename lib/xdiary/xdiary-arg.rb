# --------------------
# xdiary-arg.rb
# --------------------

module Xdiary

  class CheckStart
    def initialize(arg)
      @err = false
      k, @h = nil, Hash.new
      begin
        arg.each{|x| m = /^-(.*)/.match(x); (m) ? (k = m[1].to_sym; @h[k] = nil) : @h[k] ||= x}
      rescue
        return @err = "Error"
      end
      @h[:today] = Time.now if @h.has_key?(:today)
    end

    def base
      return help if (@h.has_key?(:h) or @h.has_key?(:help))
      return @err if check_opt
      return @err if check_time
      return @err if check_l
      return @err if check_d
      return [@err, @h]
    end

    def check_opt
      @h.keys.each{|k| @err = "Error: No option" unless arg_keys["-#{k}"] }
      @err = "Error: Option" if (@h.has_key?(:at) && @h.has_key?(:a))
      return @err
    end

    def check_time
      t, a, err = @h[:t], @h[:at], "Error: Option DateTime'"
      return nil unless (t or a)
      (a.nil?) ? str = t : str = a
      return @err = "Error: Over charactor" if str.size > 20
      return @err = err unless /^\d{4}.\d{2}.\d{2}/.match(str)
      begin
        pt = Time.parse(str)
        (@h[:at].nil?) ? @h[:t]=pt : @h[:at]=pt
      rescue
        return @err = err
      end
      return @err
    end

    def check_l
      return nil unless num = @h[:l]
      return @err = "Error: Option -l is Over" if num.size > 2
      return @err = "Error: Option -l is Not Integer" if /\D/.match(num)
      return @err = "Error: Option -l is Zero" if num == "0"
      return @err = "Error: Option -l is Over" if num.to_i > 90
      @h[:l] = num.to_i
      return @err
    end

    def check_d
      d, err = @h[:d], "Error: -d \'2010-01\'"
      return nil unless d
      return @err = err if d.size < 5
      m = /^(\d{4})\-(\d{2})$/.match(d)
      return @err = err unless m
      return @err = err if m[2].to_i > 12
      return @err
    end

    def help
      arg_keys.sort_by{|x| x}.each{|k,v| print "#{k}: #{v}\n"}
      return 'help'
    end

    def arg_keys
      a = {
        '-a'=>"Example: -a \'NewTitle\'",
        '-at'=>"add new file without title. Example: -at \'2010/01/01/ 11:00\'",
        '-t'=>"add new file with title & time. Example: -a \'NewTitle'\ -t \'2010/01/01/ 11:00\'",
        '-d'=>"specified directory. Example: -d \'2010-01\'",
        '-l'=>"print list.",
        '-today'=>"print today list",
        '-s'=>"search in title or category, control, date",
        '-st'=>"search in content",
        '-sc'=>"search in category posted entry",
        '-h | -help'=>"this help",
      }
      return a
    end
  end

end
