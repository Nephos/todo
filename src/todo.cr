require "./todo/*"
require "option_parser"

# defaults values (dirty)
mode = nil
date = ""
id = 0
list_name = "default"
dir_name = ENV["HOME"] + "/.local/todo"
msg = ""
sort = false

# parse new values
parsed = OptionParser.parse! do |p|
  p.banner = "Usage: todo [arguments]"
  p.on("-a=ID", "--archive=ID", "Move to archive") { |i| mode = :archive; id = i.to_i32 }
  p.on("-u=ID", "--update=ID", "Update the task ID") { |i| mode = :update; id = i.to_i32 }
  p.on("-r=ID", "--remove=ID", "Delete the task ID") { |i| mode = :rm; id = i.to_i32 }
  p.on("-l=NAME", "--list=NAME", "Filter with the list NAME") { |name| list_name = name }
  p.on("-d=DATE", "--date=DATE", "Set the date") { |d| date = d }
  p.on("-s", "--sort", "Sort by date") { sort = true }
  p.on("-h", "--help", "Show this help") { puts p; exit }
  p.unknown_args { |args| (mode = :add if mode.nil?; msg = args.join(" ")) unless args.empty? }
end
Dir.mkdir_p(dir_name)
mode ||= :list

# new list
list = List.new(list_name)
list.load(dir_name)

# effect
if mode == :add
  todo = Todo.new(msg, date)
  list << todo
  puts "Add: #{todo.msg}\t#{todo.date}"
elsif mode == :list
  display = [] of Array(String)
  list.each_with_index { |todo, idx| display << [todo.date, "#{idx.to_s.rjust(4, ' ')} #{todo.date.rjust(12, ' ')} #{todo.msg}"] }
  display.sort_by! { |e| e[0] } if sort
  puts display.map { |e| e[1] }.join("\n")
elsif mode == :rm
  list.rm(id)
  puts "Remove: #{id}"
elsif mode == :update
  list[id].msg = msg
  list[id].date = date
  puts "Update: #{id}"
elsif mode == :archive
  todo = list[id]
  archives = List.new("archive")
  archives << todo
  archives.save
  list.rm(id)
  puts "Archive: #{id}"
else
  puts "Error"
end

list.save(dir_name)
# puts "Save list"
