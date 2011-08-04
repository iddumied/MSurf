class String
  def join
    return self
  end
end


class History
  def initialize file
    @file = file.each_line.to_a.reverse.map{|e| e.chop}
    @history = [] 
    Dir.mkdir("#{`echo $HOME`.chop}/.surf") unless Dir.exist?("#{`echo $HOME`.chop}/.surf")
    Dir.mkdir("#{`echo $HOME`.chop}/.surf/.history") unless Dir.exist?("#{`echo $HOME`.chop}/.surf/.history")

    @curdate = { :year => Time.now.year, :month => Time.now.month, :day => Time.now.day, :hour => Time.now.hour, :minute => Time.now.min, :second => Time.now.sec } 
  end
  
  def parse
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
  end

  def group_by_date
    history_ary = @history
    @history = { :today => [], :yesterday => [], :lastweek => [], :lastmonth => [], :lastyear => [], :lastyears => [] }
    
    @history[:today]     << history_ary.delete_at(0) until history_ary.empty? or time_div( history_ary.first[:date], @curdate )[:day]   == 1 
    @history[:yesterday] << history_ary.delete_at(0) until history_ary.empty? or time_div( history_ary.first[:date], @curdate )[:day]   == 2
    @history[:lastweek]  << history_ary.delete_at(0) until history_ary.empty? or time_div( history_ary.first[:date], @curdate )[:day]   == 7
    @history[:lasmonth]  << history_ary.delete_at(0) until history_ary.empty? or time_div( history_ary.first[:date], @curdate )[:month] == 1
    @history[:lastyear]  << history_ary.delete_at(0) until history_ary.empty? or time_div( history_ary.first[:date], @curdate )[:year]  == 1
    @history[:lastyears] << history_ary.delete_at(0) until history_ary.empty?
  end

  def debug
    @history.each do |e|
      puts e.inspect
    end
  end

  def time_div start, ende
    div = Hash.new

    ende.each { |k,v| div[k] = v - start[k] }
    
    div[:minute] -= 1 if div[:second] < 0
    div[:hour]   -= 1 if div[:minute] < 0
    div[:day]    -= 1 if div[:hour]   < 0
    div[:month]  -= 1 if div[:day]    < 0
    div[:year]   -= 1 if div[:month]  < 0
      
    return div
  end

end

if __FILE__ == $0
  history = History.new( File.open("#{`echo $HOME`.chop}/.surf/history.txt", :encoding => "BINARY") )
  history.parse
  history.group_by_date
  history.debug
end
