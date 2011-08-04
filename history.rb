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
    @info = File.open("#{`echo $HOME`.chop}/.surf/.history/info") if File.exist?("#{`echo $HOME`.chop}/.surf/.history/info")
    @agent = Mechanize.new
    #@page = @agent.get(page)
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

  def debug
    @history.each do |e|
      puts e.inspect
    end
  end

end

if __FILE__ == $0
  history = History.new( File.open("#{`echo $HOME`.chop}/.surf/history.txt", :encoding => "BINARY") )
  history.parse
  history.debug
end
