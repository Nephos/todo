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

  # :nodoc:
  # calls config.exec with the arguments
  private macro config_exec(config_to_exec)
    config.exec {{config_to_exec}}, mode, date, id, list_name, dir_name, msg, sort
  end

  def run(mode, date, id, list_name, dir_name, msg, sort)
    config = Config.new

    # Prepare the list
    config_exec "before_load"
    list = List.load(list_name, dir_name)
    config_exec "after_load"

    config_exec "before_#{mode}"
    # Execute the operation
    case mode
    when :add
      todo = ::Todo::Todo.new(msg, date)
      list << todo
      puts "ADD [#{list.size - 1}] #{todo.date} #{todo.msg}"
    when :list
      display = [] of Array(String)
      list.each_with_index do |todo, idx|
        p_id = idx.to_s.rjust(4, ' ').colorize.yellow
        p_date_time = Time.parse(todo.date, ::Todo::Todo::DATE_FORMAT) rescue nil
        p_date_red = p_date_time && p_date_time < Time.now
        p_date = todo.date.rjust(12, ' ').colorize.fore(p_date_red ? :red : :white).mode(p_date_red ? :bright : :dim).to_s
        display << [todo.date, "#{p_id} | #{p_date} | #{todo.msg}"]
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
    config_exec "after_#{mode}"

    # Save the operation
    config_exec "before_save"
    list.save(list_name, dir_name)
    config_exec "after_save"
  end
end
