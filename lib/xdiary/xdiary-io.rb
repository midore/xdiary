# --------------------
# xdiary-io.rb
# --------------------

module Xdiary
  module Setting
    def check_conf
      return false unless File.exist?(data_dir)
      @text_dir, @trash_dir = File.join(data_dir, 'text'), File.join(data_dir, 'trash')
      mkd(@text_dir) unless check_dir(@text_dir)
      mkd(@trash_dir) unless check_dir(@trash_dir)
      return true
    end

    def check_dir(d)
      e = []
      e << File.exist?(d)
      e << File.directory?(d)
      e << File.readable?(d)
      e << File.writable?(d)
      e << File.executable?(d)
      return true unless e.include?(false)
      return false
    end

    def mkd(d=nil)
      begin
        Dir.mkdir(d)
        print "maked directory #{d}\n"
      end
    end
  end

  module Writer
    def writer(path, data)
      File.open(path, 'w:utf-8'){|f| f.print data}
      # print "Saved: #{path}\n"
    end
  end

  module Reader
    def reader(path)
      return nil unless File.exist?(path)
      IO.readlines(path)
    end

    def view_h(path)
      a, mark = [], /^--content$/
      IO.foreach(path){|line|
        break if line.match(mark)
        a.push(line)
      }
      return ary_to_h(a, path)
    end

    def find_index(path)
      h = view_h(path)
      return nil unless h
      unless @plus
        m = h.values.select{|v| v.match(@word)}
        return h unless m.empty?
      else
        return h unless h[:control] == 'yes'
      end
    end

    def find_content(path)
      i, m = nil, nil
      a, mark = [], /^--content$/
      IO.foreach(path.to_s){|line|
        if line.match(mark)
          i = true; next
        end
        (i.nil?) ? a.push(line) : m = line.match(@word)
        break if m
      }
      return ary_to_h(a, path) if m
    end

    def ary_to_h(ary, path)
      h, k = Hash.new, nil
      ary.each{|x|
        hit = x.match(/--(.*)\n$/)
        k = hit[1].to_sym if hit
        h[k] = x.strip unless hit
      }
      h[:path] = path
      return h
    end
  end

  module Osa
    def viaosa(path)
      editor_path = "/usr/bin/vim"
      begin
      # OS X MacVim ver 7.3
      system("/usr/bin/osascript -e 'Tell application \"MacVim\" to open (POSIX file \"#{path}\") as string' -e 'return'")
      # OS X /usr/bin/vim
      # system("/usr/bin/osascript -e 'Tell application \"Terminal\" to do script \"#{editor_path} \" & \"#{path}\"'")
      end
    end
  end

  Setting.send(:include, $XDIARYCONF)
  # end of moudle
end

