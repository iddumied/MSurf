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
    @historyb, @historyf, @saved = [],[],false
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
      
      group = line.split("::")
      group.delete_at(0)
      group.delete_at(group.length-1)
      title = line.sub("::","CATONTHISPOSITION").sub("::","CATONTHISPOSITION").reverse.sub("::","CATONTHISPOSITION".reverse).reverse.split("CATONTHISPOSITION")[2]
      group = group.first

      @bookmarks << { :date => date, :url => line.split("::").last, :title => title, :group => group }
    end
  end

  def group
    @groups = []
    
    @bookmarks.each { |hash| @groups << hash[:group] }
    bookmark_ary = @bookmarks
    @bookmarks = Hash.new

    @groups.uniq!.each { |group| @bookmarks.store( group, [] ) }
    
    @bookmarks.keys.each do |group|
      bookmark_ary.each do |hash|  
        @bookmarks[group] << hash if hash[:group] == group 
      end
    end
  end

  def list(pgroup = true, url = false)
    if  pgroup == true
    
    elsif pgroup < 0 or pgroup >= @groups.length
      puts "There is no group #{pgroup}"    
      return false
    
    end

    length = Curses.init_screen.maxx
    Curses.close_screen

    @bookmarks.each do |group,elements|
      i = @groups.find_index(group)
      if pgroup == true or pgroup == i 
        puts "(#{i}) #{group}"
        elements.each_with_index do |e,i| 
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

  # parameter surce group, surce element, targte group
  def shift sg, se, tg
    if sg < 0 or sg >= @groups.length 
      puts "There is no group #{sg}"    
      return false
    
    elsif tg < 0 or tg >= @groups.length
      puts "There is no group #{tg}"    
      return false
    
    elsif @bookmarks[@groups[sg]][se].nil?
      puts "group #{@groups[sg]} has no entrie #{se}"
      return false

    elsif tg == sg
      puts "Warning target group == source group"
    end


    @historyf = []
    output = "#{@groups[sg]}: #{@bookmarks[@groups[sg]][se][:title]} => #{@groups[tg]}"

    @historyb << { output => clone }
    
    @bookmarks[@groups[sg]][se][:group] = @groups[tg].clone
    @bookmarks[@groups[tg]] << @bookmarks[@groups[sg]].delete_at(se)
    
    puts output
    @saved = false 
  end

  def clone bookmark = @bookmarks
    cl = Hash.new
    bookmark.each do |group,ary|
      cl.store(group, Array.new)
      ary.each do |hash|
        cl[group] << Hash.new
        hash.each do |k,v|
          cl[group][cl[group].length-1].store(k,v.clone)
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
    @bookmarks = clone( @historyb.delete_at(@historyb.length-1).values.first )
    @groups = @bookmarks.keys
    @saved = false
  end
  
  def step_for
    if @historyf.empty?
      puts "Already at newest change"
      return false
    end

    @historyb << { @historyf.last.keys.first => clone }
    puts "redo :: #{@historyf.last.keys.first}"    
    @bookmarks = clone( @historyf.delete_at(@historyf.length-1).values.first )
    @groups = @bookmarks.keys
    @saved = false
  end

  def del tg, te = -1
    if tg < 0 or tg >= @groups.length
      puts "There is no group #{tg}"    
      return false
    
    elsif te == -1
       puts "Warning deleting group"

    elsif @bookmarks[@groups[tg]][te].nil?
      puts "group #{@groups[tg]} has no entrie #{se}"
      return false

    end

    @historyf = []
    if te == -1
      output = "delete => #{@groups[tg]}"

      @historyb << { output => clone }
      @bookmarks.delete(@groups[tg])

    else
      output = "delete => #{@groups[tg]}: #{@bookmarks[@groups[tg]][te][:title]}"

      @historyb << { output => clone }
      @bookmarks[@groups[tg]].delete_at(te)
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
    @bookmarks.each do |k,v|
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

      file.puts "#{date}::#{entry[:group]}::#{entry[:title]}::#{entry[:url]}"
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

  def rename_group( group, name )
    if group < 0 or group >= @groups.length 
      puts "There is no group #{group}"    
      return false
    end

    @historyf = []
    output = "renamed: #{@groups[group]} => #{name}"
    @historyb << { output => clone }

    @bookmarks[name] = @bookmarks.delete(@groups[group]).map{|hash| hash[:group] = name; hash }
    @groups[group] = name
    puts output
  end

  def rename_bookmark( g,e, name )
    if g < 0 or g >= @groups.length 
      puts "There is no group #{g}"    
      return false
    
    elsif @bookmarks[@groups[g]][e].nil?
      puts "group #{@groups[g]} has no entrie #{e}"
      return false

    end

    @historyf = []
    output = "renamed: #{@groups[g]}: #{@bookmarks[@groups[g]][e][:title]} => #{name}"
    @historyb << { output => clone }
    
    if Dir.entries("#{`echo $HOME`.chop}/.surf/.history/.icons/").include? "#{name}.ico"
      puts "Error icon #{name}.ico exists"
      return false

    else system "cp '#{`echo $HOME`.chop}/.surf/.history/.icons/#{@bookmarks[@groups[g]][e][:title]}.ico' '#{`echo $HOME`.chop}/.surf/.history/.icons/#{name}.ico'" end

    puts "added icon #{name}.ico"

    @bookmarks[@groups[g]][e][:title] = name
    puts output
  end

end

if __FILE__ == $0
  bookmark = Bookmark.new( File.open("#{ENV[ "HOME" ]}/.surf/bookmark.txt", :encoding => "BINARY") )
  bookmark.parse
  bookmark.group
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
       else bookmark.list( input.join.to_i, url )
       end
      
    elsif input.split(" ").length == 4 and ["s", "shift", "m", "move"].include?( input.split(" ").first )
      input = input.split(" ").map{ |e| e.to_i }
      bookmark.shift(input[1], input[2], input[3])

    elsif ["r","redo"].include? input
      bookmark.step_for

    elsif ["u","undo"].include? input
      bookmark.step_back

    elsif ["h", "help"].include? input
      puts "ls <opt> <group>\t\tlist groups and etries"
      puts "  --url --all -u -a\t\t+url"
      puts "  <group>\t\t\tlist onley similar group\n\n"
      puts "q\tquit\t\t\texit programm"
      puts "u\tundo\t\t\tundo last change"
      puts "r\tredo\t\t\tredo last undone change"
      puts "d\tdel\tdelete\t\tdelete group or entrie"
      puts "  d <group> <entrie>\n\n"
      puts "s\tsave\t\t\tsave changes to bookmark.txt"
      puts "s/m\tshift/move\t\t\tmove an bookmark to another group"
      puts "  m <surce group> <bookmark> <target group>\n\n"
      puts "ng\tname-group\trename-group\t\trename a group"
      puts "  ng <group> <new name>\n\n"
      puts "nb\tname-bookmark\trename-bookmark\t\trename a bookmark"
      puts "nb <group> <bookmark> <new name>\t\t"
      
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

    elsif ["ng","name-group", "rename-group"].include? input.split(" ").first
      group = input.split(" ")[1].to_i
      name = input.sub(" ", "CATONTHISPOSITION").sub(" ", "CATONTHISPOSITION").split("CATONTHISPOSITION").last
      bookmark.rename_group group, name
      
    elsif ["nb","name-bookmark", "rename-bookmark"].include? input.split(" ").first
      g = input.split(" ")[1].to_i
      e = input.split(" ")[2].to_i
      name = input.sub(" ", "CATONTHISPOSITION").sub(" ", "CATONTHISPOSITION").sub(" ", "CATONTHISPOSITION").split("CATONTHISPOSITION").last
      bookmark.rename_bookmark g, e, name
      
    end
  end
end
