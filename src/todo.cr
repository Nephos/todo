require "./todo/*"
require "option_parser"

# defaults values (dirty)
mode = nil
date = ""
id = 0
list_name = "default"
dir_name = File.expand_path(".local/todo", ENV["HOME"])
msg = ""
sort = :date

# parse new values
parsed = OptionParser.parse! do |p|
  p.banner = "todo\nauthor: Nephos\nversion: #{Todo::VERSION}\n\nUsage: todo [arguments]"
  p.on("-a=ID", "--archive=ID", "Move to archive") { |i| mode = :archive; id = i.to_i32 }
  p.on("-u=ID", "--update=ID", "Update the task ID") { |i| mode = :update; id = i.to_i32 }
  p.on("-r=ID", "--remove=ID", "Delete the task ID") { |i| mode = :rm; id = i.to_i32 }
  p.on("-d=DATE", "--date=DATE", "Set the date") { |d| date = d }
  p.on("--clear-all", "Remove everything in the list") { mode = :clear_all }

  p.on("-l=NAME", "--list=NAME", "Filter with the list NAME") { |name| list_name = name }
  p.on("--directory=PATH", "Change the directory of the todolist") { |path| dir_name = path }

  p.on("-s", "--sort", "Sort by date (by default)") { sort = :date }
  p.on("-i", "--sort-id", "Sort by id") { sort = :id }
  p.on("-v", "--version", "Show version") { puts "Todo v#{Todo::VERSION}"; exit }
  p.on("-h", "--help", "Show this help") { puts p; exit }
end
Dir.mkdir_p(dir_name)
msg = ARGV.join(" ").strip
mode = !msg.empty? ? :add : :list if mode.nil?

Todo::Exec.run(mode, date, id, list_name, dir_name, msg, sort)
