class String
  def join
    return self
  end
end


class History
  def initialize file#/*{{{*/
    @file = file.each_line.to_a.reverse.map{|e| e.chop}
    @history, @home = [],`echo $HOME`.chop
    Dir.mkdir("#{@home}/.surf") unless Dir.exist?("#{@home}/.surf")
    Dir.mkdir("#{@home}/.surf/.history") unless Dir.exist?("#{@home}/.surf/.history")
    
    @curdate = { :year => Time.now.year, :month => Time.now.month, :day => Time.now.day, :hour => Time.now.hour, :minute => Time.now.min, :second => Time.now.sec } 
  end#/*}}}*/
  
  def parse#/*{{{*/
    @file.each do |line|
      date = Hash.new
      line.split("::").first.split(":").each_with_index do |e,i| 
         e = e.to_i
         date.store( [:day,:month,:year,:hour,:minute,:second].at(i), e )
      end
      
      title = line.split("::")
      title.delete_at(0)
      title.delete_at(title.length-1)
      title = title.join
      
      @history << { :date => date, :url => line.split("::").last, :title => title }
    end
  end#/*}}}*/

  def group_by_date#/*{{{*/
    history_ary = @history
    @history = { :today => [], :yesterday => [], :lastweek => [], :lastmonth => [], :lastyear => [], :lastyears => [] }
    
    @history[:today]     << history_ary.delete_at(0) until history_ary.empty? or time_div( history_ary.first[:date], @curdate )[:day]   == 1 
    @history[:yesterday] << history_ary.delete_at(0) until history_ary.empty? or time_div( history_ary.first[:date], @curdate )[:day]   == 2
    @history[:lastweek]  << history_ary.delete_at(0) until history_ary.empty? or time_div( history_ary.first[:date], @curdate )[:day]   == 7
    @history[:lastmonth]  << history_ary.delete_at(0) until history_ary.empty? or time_div( history_ary.first[:date], @curdate )[:month] == 1
    @history[:lastyear]  << history_ary.delete_at(0) until history_ary.empty? or time_div( history_ary.first[:date], @curdate )[:year]  == 1
    @history[:lastyears] << history_ary.delete_at(0) until history_ary.empty?
  end#/*}}}*/

  def debug#/*{{{*/
    @history.each do |e|
     e.each do |f| puts f.inspect +  "\n\n" end 
    end
  end#/*}}}*/

  def time_div start, ende#/*{{{*/
    div = Hash.new

    ende.each { |k,v| div[k] = v - start[k] }
    
    div[:minute] -= 1 if div[:second] < 0
    div[:hour]   -= 1 if div[:minute] < 0
    div[:day]    -= 1 if div[:hour]   < 0
    div[:month]  -= 1 if div[:day]    < 0
    div[:year]   -= 1 if div[:month]  < 0
      
    return div
  end#/*}}}*/

  def to_html#/*{{{*/
    html = File.new("#{@home}/.surf/.history/history.html","w")
    setup_html(html)
    @history.each do |key,value|
      html.puts "<p class=\"caption\">#{key.to_s}</p>"
      value.each do |entry|
        unless [:today, :yesterday].include? key then date = sprintf("%02d.%02d.%d - %02d:%02d", entry[:date][:day], entry[:date][:month], entry[:date][:year], entry[:date][:hour], entry[:date][:minute]) 
        else date = sprintf("%02d:%02d", entry[:date][:hour], entry[:date][:minute]) end

        html.puts "  <p class=\"entry\">&nbsp;&nbsp;&nbsp;&nbsp;<img src=\"#{@home}/.surf/.history/.icons/#{entry[:title]}.ico\" height=\"16px\" width=\"16px\" /> #{date} "
        html.puts "    <a href=\"#{entry[:url]}\" target=\"_blank\">#{entry[:title]}</a>"
        html.puts "  </p>"
      end
    end
  end#/*}}}*/

  def setup_html( html )#/*{{{*/
    html.puts "<html><head><title>History</title>"
    html.puts "<link rel=\"icon\" href=\"history.ico\" type=\"image/ico\" />"
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
  end#/*}}}*/

  def filter arg
    @history.each do |k,v|
      v.map! do |hash|
        if hash[:url].include? arg or hash[:title].include? arg
          hash
        else nil end
      end
      v.delete( nil )
      @history.delete(k) if v.empty?
    end  
  end

end

if __FILE__ == $0
  input = `echo \"Search History\"| dmenu -fn \"-artwiz-cureextra-medium-r-normal--11-110-75-75-p-90-iso8859-1\" -sb \"#000000\" -nb \"#000000\" -nf \"#ffffff\" -sf \"#00aaff\"`.chop
  history = History.new( File.open("#{`echo $HOME`.chop}/.surf/history.txt", :encoding => "BINARY") )
  history.parse
  history.group_by_date
  history.filter( input ) unless input == "Search History"
  history.to_html
  system "xprop -id #{ARGV[0]} -f _SURF_GO 8s -set _SURF_GO file://#{`echo $HOME`.chop}/.surf/.history/history.html"
end
