# --------------------
# xdiay-main.rb
# --------------------

module Xdiary

  class Main
    include Setting

    def initialize(h)
      return print "Error: Look your 'xdiary_conf' \n" unless check_conf
      @num = h[:l] ||= default_n
      @h, @d  = h, h[:d]
      @h.delete(:d)
      (@d.nil?) ? @dir = @text_dir : @dir = File.join(@text_dir, @d)
      command
    end

    private

    def command
      case @h.keys.to_s
      when /today/
        run_today
      when /s|st|sc/
        run_search
      when /at|a/
        run_add
      when "l"
        run_view
      end
    end

    def run_view
      a = View.new(@dir, @num).base
      run_request(a)
    end

    def run_search
      opt = @h[:st]
      w = @h[:s]
      w ||= @h[:st]
      w ||= @h[:sc]
      return print "Error: Search word error\n" unless w
      a = Search.new(@dir, @num)
      w = nil if /\+/.match(w)
      a.plus = 'plus' if (@h[:sc] or w.nil? )
      a.opt = @h[:st]
      res = a.base(w)
      run_request(res) if res
    end

    def run_today
      w = @h[:today].strftime("%Y/%m/%d")
      a = Search.new(@dir, @num).base(w, nil)
      (return print "Not found.\n") if a.empty?
      run_request(a)
    end

    def run_request(a)
      return nil if a.empty?
      a.each_with_index{|x,y| print y + 1; x.to_s}
      Request.new(a, @trash_dir).base
    end

    def run_add
      title = @h[:a] ||= default_title
      t = @h[:t] ||= @h[:at] ||=Time.now
      d = File.join(@text_dir, t.strftime("%Y-%m"))
      f = Add.new(d, title, t).base
      edit(f) if f
    end

    def edit(f)
      return false unless File.exist?(f)
      Request.new(nil, @trash_dir).text_open(f)
    end
  end

  class Add
    include Writer

    def initialize(d, title, t)
      @d, @title, @t = d, title, t
      @f = File.join(d, t.strftime("%Y-%m-%dT%H-%M-%S.txt"))
    end

    def base
      return print "Same name file exist.\n" if File.exist?(@f)
      unless File.exist?(@d)
        return nil unless make_dir
      end
      make_file
      return @f
    end

    private

    def make_file
      text = Diary.new(@title, @t).draft
      writer(@f, text)
    end

    def make_dir
      begin
        Dir.mkdir(@d)
        print "maked directory: #{@d}\n"
      rescue
        print "Error: make directory.\"#{@d}\"\n"
        return false
      end
      return true if File.exist?(@d)
    end
  end

  class Diary
    def initialize(title=nil, t=nil)
      @title, @created = title, t
      @control, @category = 'yes', 'diary'
      @path = nil, @content = nil
    end

    attr_reader :path, :category

    def to_s
      ary = [posted?, created_s, @title, @category]
      printf "\t[%s]\s[%-16s]\s[%s]\s(%s)\n" % ary
    end

    def to_txt(a)
      str = ""
      a.each{|i| str << "--#{i}\n#{self["@#{i}"]}\n"}
      return str
    end

    def draft
      @date = created_s
      a = ['date', 'control', 'category', 'title', 'content']
      to_txt(a)
    end

    def detail
      ins_a.each{|i| print i, "\s:", self[i], "\n"}
    end

    def load_up(h)
      h.each{|k,v| self["@#{k.to_s}"] = v}
      return self
    end

    private

    alias ins_a instance_variables
    alias []= instance_variable_set
    alias [] instance_variable_get

    def created_s
      @created.strftime("%Y/%m/%d %a %p %H:%M:%S")
    end

    def posted?
      @control == "yes" ? "-" : "+"
    end
  end

  class View
    include Reader

    def initialize(d, n)
      @ary, @d, @n = Array.new, d, n
    end

    def base
      set_ary
    end

    private

    def set_ary
      Find.find(@d){|i|
        break if @ary.size == @n
        next unless File.extname(i) == '.txt'
        diary = get_diary(i)
        next if diary.nil?
        @ary << diary
      }
      return @ary
    end

    def get_diary(x)
      begin
        h = view_h(x)
        to_obj(h) unless h.empty?
      rescue
        return nil
      end
    end

    def to_obj(h)
      t = Time.parse(h[:date])
      Diary.new(nil, t).load_up(h)
    end
  end

  class Search < View
    def initialize(d, n)
      @ary, @d, @n = Array.new, d, n
      @opt, @word = nil, nil
    end

    attr_writer :plus, :opt

    def base(w)
      @word = Regexp.new(w, true) if w
      set_ary
    end

    private

    def get_diary(x)
      unless @plus
        h = find_index(x) unless @opt
        h = find_content(x) if @opt
      else
        h = find_posted(x) unless @word
        h = find_posted_category(x) if @word
      end
      to_obj(h) unless h.nil?
    end
  end

  class Request
    self.send(:include, Osa)

    def initialize(a, trash)
      @ary, @trash = a, trash
      @diary = nil
    end

    def base
      @diary = @ary[0] if @ary.size == 1
      unless @diary
        n = select_no
        @diary = @ary[n-1] if n
      end
      return nil if @diary.nil?
      run_req(select_req)
    end

    def run_req(req)
      @ary = nil
      case req
      when false then return nil
      when 'i' then @diary.detail
      when 'r' then text_remove(@diary.path)
      when 'e' then text_open(@diary.path)
      end
    end

    def text_open(f)
      return false unless File.exist?(f)
      viaosa(f)
    end

    private

    def text_remove(path)
      return nil unless File.exist?(path)
      new = File.join(@trash, File.basename(path))
      begin
        File.rename(path, new)
        print "Removed: #{new}\n"
      rescue
        return print "Error: trash directory\n"
      end
    end

    def select_no
      Select.new.base("Select NO", @ary.size)
    end

    def select_req
      str = "Select [i/e/r]"
      Select.new.base(str, false)
    end
  end

  class Select
    def base(str, opt)
      return false unless $stdin.tty?
      begin
        print "#{str}:\n"
        ans = $stdin.gets.chomp
        exit if /^n$|^no$/.match(ans)
        exit if ans.empty?
        case opt
        when true   # yes or no
          m = /^y$|^yes$/.match(ans)
          exit unless m
          return true
        when false  # return alphabet
          exit if (/\d/.match(ans) or ans.size > 7)
          return ans
        else        # return number
          i_ans = ans.to_i
          exit unless ans
          exit if (i_ans > opt or ans =~ /\D/)
          return i_ans
        end
      rescue SignalException
        exit
      end
    end
  end

end

