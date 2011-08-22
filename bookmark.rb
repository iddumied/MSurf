class String
  def join
    return self
  end
end


class Bookmark
  def initialize file
    @file = file.each_line.to_a.reverse.map{|e| e.chop}
    @bookmark = []
    Dir.mkdir("#{ENV[ "HOME" ]}/.surf") unless Dir.exist?("#{ENV[ "HOME" ]}/.surf")
    Dir.mkdir("#{ENV[ "HOME" ]}/.surf/.bookmark") unless Dir.exist?("#{ENV[ "HOME" ]}/.surf/.bookmark")
    
    @curdate = time_now_hash 
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
      title = line.sub("::","CATONTHISPOSITION").sub("::","CATONTHISPOSITION").reverse.sub("::","CATONTHISPOSITION".reverse).reverse.split("CATONTHISPOSITION")[2]
      groub = groub.first

      @bookmark << { :date => date, :url => line.split("::").last, :title => title, :groub => groub }
    end
  end

  def groub
    groubs = []
    
    @bookmark.each { |hash| groubs << hash[:groub] }
    bookmark_ary = @bookmark
    @bookmark = Hash.new

    groubs.uniq.each { |groub| @bookmark.store( groub, [] ) }
    
    @bookmark.keys.each do |groub|
      bookmark_ary.each do |hash|  
        @bookmark[groub] << hash if hash[:groub] == groub 
      end
    end
  end

  def to_html
    html = File.new("#{ENV[ "HOME" ]}/.surf/.bookmark/bookmark.html","w")
    setup_html(html)
    @bookmark.each do |key,value|
      html.puts "<p class=\"caption\">#{key.to_s}</p>"
      value.each do |entry|
        date = sprintf("%02d.%02d.%d - %02d:%02d", entry[:date][:day], entry[:date][:month], entry[:date][:year], entry[:date][:hour], entry[:date][:minute]) 

        html.puts "  <p class=\"entry\">&nbsp;&nbsp;&nbsp;&nbsp;<img src=\"#{ENV[ "HOME" ]}/.surf/.history/.icons/#{entry[:title]}.ico\" height=\"16px\" width=\"16px\" /> #{date} "
        html.puts "    <a href=\"#{entry[:url]}\" target=\"_blank\">#{entry[:title]}</a>"
        html.puts "  </p>"
      end
    end
  end

  def setup_html( html )
    html.puts "<html><head><title>Bookmarks</title>"
    html.puts "<link rel=\"icon\" href=\"bookmark.ico\" type=\"image/ico\" />"
    html.puts "<style type=\"text/css\">"
    html.puts ".caption {"
    html.puts "  font-size: 22px;"
    html.puts "  font-weight: bold;"
    html.puts "}"
    html.puts ".entry {"
    html.puts "  font-size: 12px;"
    html.puts "  line-height: 30%;"
    html.puts "}"
    html.puts "</style>"
  end

  def filter arg
    @bookmark.each do |k,v|
      v.map! do |hash|
        if hash[:url].include? arg or hash[:title].include? arg or hash[:groub].include? arg
          hash
        else nil end
      end
      v.delete( nil )
      @bookmark.delete(k) if v.empty?
    end  
    
  end

end

if __FILE__ == $0
  input = `echo \"Search Bookmarks\"| dmenu -fn \"-artwiz-cureextra-medium-r-normal--11-110-75-75-p-90-iso8859-1\" -sb \"#000000\" -nb \"#000000\" -nf \"#ffffff\" -sf \"#00aaff\"`.chop
  bookmark = Bookmark.new( File.open("#{ENV[ "HOME" ]}/.surf/bookmark.txt", :encoding => "BINARY") )
  bookmark.parse
  bookmark.groub
  bookmark.filter( input ) unless input == "Search Bookmarks"
  bookmark.to_html
  system "xprop -id #{ARGV[0]} -f _SURF_GO 8s -set _SURF_GO file://#{ENV[ "HOME" ]}/.surf/.bookmark/bookmark.html"
end
