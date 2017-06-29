require "colorize"
require "./todo"
require "./list"

module Todo::Exec
  extend self
  private def copy_task(task, list_to, dir_name)
    list = List.load(list_to, dir_name)
    list << task
    list.save(list_to, dir_name)
  end

  def run(mode, date, id, list_name, dir_name, msg, sort)
    config = Config.new

    # new list
    config.exec "before_load"
    list = List.load(list_name, dir_name)
    config.exec "after_load"

    config.exec "before_#{mode}"
    # effect
    case mode
    when :add
      todo = ::Todo::Todo.new(msg, date)
      list << todo
      puts "ADD [#{list.size - 1}] #{todo.date} #{todo.msg}"
    when :list
      display = [] of Array(String)
      list.each_with_index do |todo, idx|
        id = idx.to_s.rjust(4, ' ').colorize.yellow
        date_time = Time.parse(todo.date, ::Todo::Todo::DATE_FORMAT) rescue nil
        date_red = date_time && date_time < Time.now
        date = todo.date.rjust(12, ' ').colorize.fore(date_red ? :red : :white).mode(date_red ? :bright : :dim).to_s
        display << [todo.date, "#{id} | #{date} | #{todo.msg}"]
      end
      display.sort_by! { |e| e[0] } if sort == :date
      max_msg_len = [list.reduce(7) { |l, r| [l, r.msg.size].max }, 58].min
      puts "  id |         date | message"
      puts "---- | ------------ | #{"-" * max_msg_len} "
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
      copy_task(todo, "archives", dir_name)
      list.rm(id)
      puts "ARCHIVE [#{id}] #{todo.msg}"
    when :clear_all
      list.clear
    else
      puts "Error"
    end
    config.exec "after_#{mode}"

    config.exec "before_save"
    list.save(list_name, dir_name)
    config.exec "after_save"
  end
end
