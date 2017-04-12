require "yaml"
require "./todo"

class Todo::List
  def self.load(path : String)
    # File.open(path, "a") { }
    data = (File.read(path) rescue "{\"todos\":[]}")
    List.from_yaml(data)
  end

  def self.load(list_name : String, dir_name : String)
    List.load(File.expand_path(list_name, dir_name))
  end

  property name
  YAML.mapping(
    todos: {type: Array(Todo), setter: false, nilable: false},
  )

  def save(list_name : String, dir_name : String)
    save(File.expand_path(list_name, dir_name))
  end

  def save(path : String)
    File.write(path, self.to_yaml)
    self
  end

  def <<(todo : Todo)
    self.todos << todo
  end

  def [](id : Int32)
    self.todos[id]
  end

  def rm(id : Int32)
    self.todos.delete_at id rescue nil
  end

  delegate map_with_index, to: todos
  delegate each_with_index, to: todos
  delegate size, to: todos
  delegate clear, to: todos
end
