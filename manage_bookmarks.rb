require 'curses'

class String
  def join
    return self
  end
end


class Bookmark
  def initialize file
    @file = file.each_line.to_a.reverse.map{|e| e.chop}
    @bookmark, @home = [],`echo $HOME`.chop
    Dir.mkdir("#{@home}/.surf") unless Dir.exist?("#{@home}/.surf")
    Dir.mkdir("#{@home}/.surf/.bookmark") unless Dir.exist?("#{@home}/.surf/.bookmark")
    
    @curdate = { :year => Time.now.year, :month => Time.now.month, :day => Time.now.day, :hour => Time.now.hour, :minute => Time.now.min, :second => Time.now.sec } 
    @historyb, @historyf, @saved = [],[],false
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
      title = line.sub("::","CATONTHISPOSITION").sub("::","CATONTHISPOSITION").reverse.sub("::","CATONTHISPOSITION".reverse).reverse.split("CATONTHISPOSITION")[2]
      groub = groub.first

      @bookmark << { :date => date, :url => line.split("::").last, :title => title, :groub => groub }
    end
  end

  def groub
    @groubs = []
    
    @bookmark.each { |hash| @groubs << hash[:groub] }
    bookmark_ary = @bookmark
    @bookmark = Hash.new

    @groubs.uniq!.each { |groub| @bookmark.store( groub, [] ) }
    
    @bookmark.keys.each do |groub|
      bookmark_ary.each do |hash|  
        @bookmark[groub] << hash if hash[:groub] == groub 
      end
    end
  end

  def list(pgroub = true, url = false)
    if  pgroub == true
    
    elsif pgroub < 0 or pgroub >= @groubs.length
      puts "There is no Groub #{pgroub}"    
      return false
    
    end




    length = Curses.init_screen.maxx
    Curses.close_screen

    @bookmark.each do |groub,elemnts|
      i = @groubs.find_index(groub)
      if pgroub == true or pgroub == i 
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
    if sg < 0 or sg >= @groubs.length 
      puts "There is no Groub #{sg}"    
      return false
    
    elsif tg < 0 or tg >= @groubs.length
      puts "There is no Groub #{tg}"    
      return false
    
    elsif @bookmark[@groubs[sg]][se].nil?
      puts "Groub #{@groubs[sg]} has no entrie #{se}"
      return false

    elsif tg == sg
      puts "Warning target groub == source groub"
    end


    @historyf = []
    output = "#{@groubs[sg]}: #{@bookmark[@groubs[sg]][se][:title]} => #{@groubs[tg]}"

    @historyb << { output => clone }
    
    @bookmark[@groubs[sg]][se][:groub] = @groubs[tg].clone
    @bookmark[@groubs[tg]] << @bookmark[@groubs[sg]].delete_at(se)
    
    puts output
    @saved = false 
  end

  def clone bookmark = @bookmark
    cl = Hash.new
    bookmark.each do |groub,ary|
      cl.store(groub, Array.new)
      ary.each do |hash|
        cl[groub] << Hash.new
        hash.each do |k,v|
          cl[groub][cl[groub].length-1].store(k,v.clone)
        end
      end
    end
    
    return cl
  end

  def step_back
    if @historyb.empty?
      puts "Already at oldest change"
      return false
    end

    @historyf << { @historyb.last.keys.first => clone }
    puts "undo :: #{@historyb.last.keys.first}"    
    @bookmark = clone( @historyb.delete_at(@historyb.length-1).values.first )
    @groubs = @bookmark.keys
    @saved = false
  end
  
  def step_for
    if @historyf.empty?
      puts "Already at newest change"
      return false
    end

    @historyb << { @historyf.last.keys.first => clone }
    puts "redo :: #{@historyf.last.keys.first}"    
    @bookmark = clone( @historyf.delete_at(@historyf.length-1).values.first )
    @groubs = @bookmark.keys
    @saved = false
  end

  def del tg, te = -1
    if tg < 0 or tg >= @groubs.length
      puts "There is no Groub #{tg}"    
      return false
    
    elsif te == -1
       puts "Warning deleting groub"

    elsif @bookmark[@groubs[tg]][te].nil?
      puts "Groub #{@groubs[tg]} has no entrie #{se}"
      return false

    end

    @historyf = []
    if te == -1
      output = "delete => #{@groubs[tg]}"

      @historyb << { output => clone }
      @bookmark.delete(@groubs[tg])

    else
      output = "delete => #{@groubs[tg]}: #{@bookmark[@groubs[tg]][te][:title]}"

      @historyb << { output => clone }
      @bookmark[@groubs[tg]].delete_at(te)
    end
    
    puts output
    @saved = false
  end

  def save
    number = 0
    Dir.entries("#{`echo $HOME`.chop}/.surf/.bookmark/").each do |e|
      if e.include?("bookmark.txt.old.")
        tmp = e.split(".").last.to_i
        number = tmp if tmp > number
      end
    end
    number += 1
    
    system "cp #{`echo $HOME`.chop}/.surf/bookmark.txt #{`echo $HOME`.chop}/.surf/.bookmark/bookmark.txt.old.#{number}"
    puts "backup bookmark.txt => bookmark.txt.old.#{number}"

    ary = []
    @bookmark.each do |k,v|
      v.each do |entry|
        ary << [ entry[:date][:second] + entry[:date][:minute]*60 +
                  entry[:date][:hour]*60*60 + entry[:date][:day]*60*60*24 +
                  entry[:date][:month]*60*60*24*31 + entry[:date][:year]*60*60*24*31*12, entry ]
      end
    end

    
    file = File.open("#{`echo $HOME`.chop}/.surf/bookmark.txt", "w")
    until ary.empty?
      entry = del_min( ary )

      date = sprintf("%02d:%02d:%d:%02d:%02d:%02d",entry[:date][:day], entry[:date][:month],
                            entry[:date][:year], entry[:date][:hour], entry[:date][:minute],
                            entry[:date][:second] ) 

      file.puts "#{date}::#{entry[:groub]}::#{entry[:title]}::#{entry[:url]}"
    end
    file.close
    puts "saved #{@historyb.length} changes to bookmark.txt"
  end

  def del_min( ary )
    max = ary.first
    index = 0
    ary.each_with_index do |e,i| 
      if e.first < max.first 
        max = e
        index = i
      end
    end

    return ary.delete_at(index).last
  end

  def rename_groub( groub, name )
    if groub < 0 or groub >= @groubs.length 
      puts "There is no Groub #{groub}"    
      return false
    end

    @historyf = []
    output = "renamed: #{@groubs[groub]} => #{name}"
    @historyb << { output => clone }

    @bookmark[name] = @bookmark.delete(@groubs[groub]).map{|hash| hash[:groub] = name; hash }
    @groubs[groub] = name
    puts output
  end

  def rename_bookmark( g,e, name )
    if g < 0 or g >= @groubs.length 
      puts "There is no Groub #{g}"    
      return false
    
    elsif @bookmark[@groubs[g]][e].nil?
      puts "Groub #{@groubs[g]} has no entrie #{e}"
      return false

    end

    @historyf = []
    output = "renamed: #{@groubs[g]}: #{@bookmark[@groubs[g]][e][:title]} => #{name}"
    @historyb << { output => clone }
    
    if Dir.entries("#{`echo $HOME`.chop}/.surf/.history/.icons/").include? "#{name}.ico"
      puts "Error icon #{name}.ico exists"
      return false

    else system "cp '#{`echo $HOME`.chop}/.surf/.history/.icons/#{@bookmark[@groubs[g]][e][:title]}.ico' '#{`echo $HOME`.chop}/.surf/.history/.icons/#{name}.ico'" end

    puts "added icon #{name}.ico"

    @bookmark[@groubs[g]][e][:title] = name
    puts output
  end

end

if __FILE__ == $0
  bookmark = Bookmark.new( File.open("#{`echo $HOME`.chop}/.surf/bookmark.txt", :encoding => "BINARY") )
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

       input.delete("--url")
       input.delete("-u")
       input.delete("--all")
       input.delete("-a")
       input.delete("ls")
       input.delete("")
       
       if input.empty?
         bookmark.list true, url
       else
         bookmark.list input.join.to_i, url
       end
      
    elsif input.split(" ").length == 4 and ["s", "shift", "m", "move"].include?( input.split(" ").first )
      input = input.split(" ").map{ |e| e.to_i }
      bookmark.shift(input[1], input[2], input[3])

    elsif ["r","redo"].include? input
      bookmark.step_for

    elsif ["u","undo"].include? input
      bookmark.step_back

    elsif ["h", "help"].include? input
      puts "ls <opt> <groub>\t\tlist groubs and etries"
      puts "  --url --all -u -a\t\t+url"
      puts "  <groub>\t\t\tlist onley similar groub\n\n"
      puts "q\tquit\t\t\texit programm"
      puts "u\tundo\t\t\tundo last change"
      puts "r\tredo\t\t\tredo last undone change"
      puts "d\tdel\tdelete\t\tdelete groub or entrie"
      puts "  d <groub> <entrie>\n\n"
      puts "s\tsave\t\t\tsave changes to bookmark.txt"
      puts "s/m\tshift/move\t\t\tmove an bookmark to another groub"
      puts "  m <surce groub> <bookmark> <target groub>\n\n"
      puts "ng\tname-groub\trename-groub\t\trename a groub"
      puts "  ng <groub> <new name>\n\n"
      puts "nb\tname-bookmark\trename-bookmark\t\trename a bookmark"
      puts "nb <groub> <bookmark> <new name>\t\t"
      
    elsif ["d","del","delete"].include?( input.split(" ").first ) and [2,3].include?( input.split(" ").length )
      input = input.split(" ")
      input.delete_at(0)
      input.map!{ |e| e.to_i }

      if input.length == 1
        bookmark.del input.first
      else
        bookmark.del input.first, input.last
      end

    elsif ["s","save"].include? input
      bookmark.save

    elsif ["ng","name-groub", "rename-groub"].include? input.split(" ").first
      groub = input.split(" ")[1].to_i
      name = input.sub(" ", "CATONTHISPOSITION").sub(" ", "CATONTHISPOSITION").split("CATONTHISPOSITION").last
      bookmark.rename_groub groub, name
      
    elsif ["nb","name-bookmark", "rename-bookmark"].include? input.split(" ").first
      g = input.split(" ")[1].to_i
      e = input.split(" ")[2].to_i
      name = input.sub(" ", "CATONTHISPOSITION").sub(" ", "CATONTHISPOSITION").sub(" ", "CATONTHISPOSITION").split("CATONTHISPOSITION").last
      bookmark.rename_bookmark g, e, name
      
    end
  end
end
