 require 'mechanize'

class History
  def initialize file
    @file = file.each_line.to_a.reverse
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

      @history << { :date => date, :url => line.split("::").last }
    end
      
  end

  def get_info
    unless @info.nil?
      #read info file
    end
    @history.each do |entry|
      page = @agent.get( entry[:url] )
      puts page.methods.inspect
      sleep 25
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
