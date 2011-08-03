require 'mechanize'

class History
  def initilaize file
    @file = file.each_line.to_a.reverse
    @history = Hash.new
    Dir.mkdir("#{`echo $HOME`.chop}/.surf") unless Dir.exist?("#{`echo $HOME`.chop}/.surf")
    Dir.mkdir("#{`echo $HOME`.chop}/.surf/.history") unless Dir.exist?("#{`echo $HOME`.chop}/.surf/.history")
    @info = File.open("#{`echo $HOME`.chop}/.surf/.history/info") if File.exist?("#{`echo $HOME`.chop}/.surf/.history/info")
  end

end
