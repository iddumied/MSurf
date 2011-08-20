require 'curses'

class String
  def join
    return self
  end
end


class Bookmark
  def initialize file
    @file = file.each_line.to_a.reverse.map{|e| e.chop}
    @bookmarks = Array.new
    Dir.mkdir("#{ENV[ "HOME" ]}/.surf") unless Dir.exist?("#{ENV[ "HOME" ]}/.surf")
    Dir.mkdir("#{ENV[ "HOME" ]}/.surf/.bookmark") unless Dir.exist?("#{ENV[ "HOME" ]}/.surf/.bookmark")
    
    @curdate = time_now_hash
    @historyb, @historyf = {},{}
  end

  def time_now_hash
    hash = Hash.new
    [ :year, :month, :day, :hour, :minute, :second ].each do |sym|
      hash[ sym ] = Time.now.__send__ sym
    end
    return hash
  end
  
  def parse
    @file.each do |line|
      date = Hash.new
      line.split("::").first.split(":").each_with_index do |e,i| 
        e = e.to_i
        date.store( [:day,:month,:year,:hour,:minute,:second].at(i), e )
      end
      
      groub = line.split("::")
      groub.delete_at(0)
      groub.delete_at(groub.length-1)
      title = groub.last
      groub.delete_at(groub.length-1)
      groub = groub.join

      @bookmarks << { :date => date, :url => line.split("::").last, :title => title, :groub => groub }
    end
  end

  def groub
    @groubs = []
    
    @bookmarks.each { |hash| @groubs << hash[:groub] }
    bookmark_ary = @bookmarks
    @bookmarks = Hash.new

    @groubs.uniq!.each { |groub| @bookmarks.store( groub, [] ) }
    
    @bookmarks.keys.each do |groub|
      bookmark_ary.each do |hash|  
        @bookmarks[groub] << hash if hash[:groub] == groub 
      end
    end
  end

  def list(pgroub = true, url = false)
    length = Curses.init_screen.maxx
    Curses.close_screen
    i = 0

    @bookmarks.each do |groub,elemnts|
      if pgroub == true or pgroub == groub
        puts "(#{i}) #{groub}"
        elemnts.each_with_index do |e,i| 
          output = "  #{i}: #{e[:title]}#{ url ? "  -  #{e[:url]}" : ""}"
          output.chop!.chop!.chop!.chop! << "..." until output.length <= (length-3)

          puts output
        end
      else next
      end
      puts "\n"

      i += 1
    end
  end

  # parameter surce groub, surce element, targte groub
  def shift sg, se, tg
    @historyf = {}
    output = "#{@groubs[sg]}: #{@bookmarks[@groubs[sg]][se][:title]} => #{@groubs[tg]}"

    @historyb.store(output, @bookmarks.clone)
    
    @bookmarks[@groubs[tg]] << @bookmarks[@groubs[sg]].delete_at(se)
    
    puts output
  end

end

if __FILE__ == $0
  bookmark = Bookmark.new( File.open("#{ENV[ "HOME" ]}/.surf/bookmark.txt", :encoding => "BINARY") )
  bookmark.parse
  bookmark.groub
  bookmark.list

  # main loop
  loop do
    print "bookmarks ~> "
    input = gets.chop 

    if ["q", "quit"].include? input
        puts "exit.."
        break
    
    elsif input == "ls"  
        bookmark.list 
    
    elsif input.split(" ").first == "ls"
       input = input.split(" ")
       url = (input.include?("--url")  or input.include?("-u") or
              input.include?("-a") or input.include?("--all")) ? true : false

      [ "--url", "-u", "--all", "-a", "ls" ].each { |s| input.delete( s ) }
       
       if input.empty? then bookmark.list( true, url )
       else bookmark.list( input.join, url )
       end
      
    elsif input.split(" ").length == 3
      input = input.split(" ").map{ |e| e.to_i }
      bookmark.shift(input[0], input[1], input[2])
    end
  end

end
