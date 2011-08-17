dmenu = `echo "$HOME/Downloads/#{ARGV[0].split("/").last}" | dmenu -fn "-artwiz-cureextra-medium-r-normal--11-110-75-75-p-90-iso8859-1" -sb "#000000" -nb "#000000" -nf "#ffffff" -sf "#00aaff"`.chop
puts `wget --load-cookies ~/.surf/cookies.txt -O "#{dmenu}" "#{ARGV.first}"`
sleep 10
