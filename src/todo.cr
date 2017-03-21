require "./todo/*"
require "option_parser"

# defaults values (dirty)
mode = :list
date = ""
rm_id = 0
list_name = "default"
dir_name = ENV["HOME"] + "/.local/todo"
data = ""

# parse new values
parsed = OptionParser.parse! do |p|
  p.banner = "Usage: todo [arguments]"
  p.on("-r=ID", "--remove=ID", "Delete the task ID") { |id| mode = :rm; rm_id =
    id.to_i32 }
  p.on("-l=NAME", "--list=NAME", "Filter with the list NAME") { |name| list_name = name }
  p.on("-d=DATE", "--date=DATE", "Set the date") { |date| list_date = date }
  p.on("-h", "--help", "Show this help") { puts p; exit }
  p.unknown_args { |args| (mode = :add; data = args.join(" ")) unless args.empty? }
end
Dir.mkdir_p(dir_name)

# new list
list = List.new(list_name)
list.load(dir_name)

# effect
# puts "Mode: #{mode}"
if mode == :add
  todo = Todo.new(data, date)
  list << todo
  puts "Add: #{todo.to_s}"
elsif mode == :list
  list.each_with_index { |todo, idx| puts "#{idx}\t#{todo.msg}\t#{todo.date}" }
elsif mode == :rm
  list.rm(rm_id)
  puts "Remove: #{rm_id}"
else
  puts "Error"
end

list.save(dir_name)
# puts "Save list"
