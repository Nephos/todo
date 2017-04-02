require "./todo/*"
require "option_parser"

# defaults values (dirty)
mode = nil
date = ""
id = 0
list_name = "default"
dir_name = ENV["HOME"] + "/.local/todo"
msg = ""
sort = :date

# parse new values
parsed = OptionParser.parse! do |p|
  p.banner = "Usage: todo [arguments]"
  p.on("-a=ID", "--archive=ID", "Move to archive") { |i| mode = :archive; id = i.to_i32 }
  p.on("-u=ID", "--update=ID", "Update the task ID") { |i| mode = :update; id = i.to_i32 }
  p.on("-r=ID", "--remove=ID", "Delete the task ID") { |i| mode = :rm; id = i.to_i32 }
  p.on("-l=NAME", "--list=NAME", "Filter with the list NAME") { |name| list_name = name }
  p.on("-d=DATE", "--date=DATE", "Set the date") { |d| date = d }
  p.on("-s", "--sort", "Sort by date (by default)") { sort = :date }
  p.on("-i", "--sort-id", "Sort by id") { sort = :id }
  p.on("-h", "--help", "Show this help") { puts p; exit }
  p.unknown_args { |args| (mode = :add if mode.nil?; msg = args.join(" ")) unless args.empty? }
end
Dir.mkdir_p(dir_name)
mode ||= :list

private def copy_task(task, list_to)
  list_to << task
  list_to.save
end

# new list
list = List.new(list_name, dir_name)
list.load(dir_name)

# effect
case mode
when :add
  todo = Todo.new(msg, date)
  list << todo
  puts "ADD [#{list.size - 1}] #{todo.date} #{todo.msg}"
when :list
  display = [] of Array(String)
  list.each_with_index { |todo, idx| display << [todo.date, "#{idx.to_s.rjust(4, ' ')} #{todo.date.rjust(12, ' ')} #{todo.msg}"] }
  display.sort_by! { |e| e[0] } if sort == :date
  puts display.map { |e| e[1] }.join("\n")
when :rm
  todo = list[id]
  list.rm(id)
  puts "RM [#{id}] #{todo.msg}"
when :update
  todo = list[id]
  list[id].msg = msg unless msg.empty?
  list[id].date = date
  puts "UP [#{id}] = (#{list[id].date}) #{list[id].msg}"
when :archive
  todo = list[id]
  copy_task(todo, List.new("archives", dir_name).load)
  list.rm(id)
  puts "ARCHIVE [#{id}] #{todo.msg}"
else
  puts "Error"
end

list.save(dir_name)
# puts "Save list"
