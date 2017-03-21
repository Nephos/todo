require "./todo"

class List
  getter todos : Array(Todo)
  property name : String

  delegate map_with_index, to: @todos
  delegate each_with_index, to: @todos

  def initialize(@name)
    @todos = Array(Todo).new
  end

  def initialize(@name, s : String)
    @todos = List.parse(s)
  end

  def to_s
    @todos.map(&.to_s).join("\n")
  end

  def save(dir : String? = nil)
    dir = dir || ENV["HOME"]
    path = File.expand_path(name, dir)
    File.write(path, self.to_s)
  end

  def load(dir : String? = nil)
    dir = dir || ENV["HOME"]
    path = File.expand_path(name, dir)
    begin
      data = File.read(path)
      @todos = List.parse(data)
    rescue
      File.open(path, "a") { }
      @todos = Array(Todo).new
    end
  end

  def <<(todo : Todo)
    @todos << todo
  end

  def [](id : Int32)
    @todos[id]
  end

  def rm(id : Int32)
    @todos.delete_at id rescue nil
  end

  def self.parse(s : String)
    s.split("\n").map { |l| Todo.new(l) }
  end
end
