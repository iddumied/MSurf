require 'mechanize'

class History
  def initilaize file
    @file = file.each_line.to_a.reverse
    @history = [] 
    Dir.mkdir("#{`echo $HOME`.chop}/.surf") unless Dir.exist?("#{`echo $HOME`.chop}/.surf")
    Dir.mkdir("#{`echo $HOME`.chop}/.surf/.history") unless Dir.exist?("#{`echo $HOME`.chop}/.surf/.history")
    @info = File.open("#{`echo $HOME`.chop}/.surf/.history/info") if File.exist?("#{`echo $HOME`.chop}/.surf/.history/info")
  end
  
  def parse
    @file.each do |line|
      date, entry = Hash.new, Hash.new
      line.split("::").first.split(":").each_with_index do |e,i| 
         e = e.to_i
         date.store( [:day,:month,:year,:hour,:minute,:second].at(i), e )
      end
    end
      
   entry.store( :date, date )
   entry.store( :url, line.split("::").last )

   @history << entry
  end

  def debug
    @history.each do |e|
      puts e.inspect
    end
  end

end

if __FILE__ == $0
  history = History.new( File.open("#{`echo $HOME`.chop}/.surf/history.txt") )
  history.parse
  history.debug
end
