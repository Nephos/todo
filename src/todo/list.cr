require "./todo"

class Todo::List
  getter todos : Array(::Todo::Todo)
  property name : String
  property dir_name : String

  delegate map_with_index, to: @todos
  delegate each_with_index, to: @todos
  delegate size, to: @todos
  delegate clear, to: @todos

  def initialize(@name, @dir_name, s : String = "")
    @todos = Array(::Todo::Todo).new
  end

  def to_s
    @todos.map(&.to_s).join("\n")
  end

  def save(dir : String? = nil)
    dir = dir || @dir_name
    path = File.expand_path(name, dir)
    File.write(path, self.to_s)
    self
  end

  def load(dir : String? = nil)
    dir = dir || @dir_name
    path = File.expand_path(name, dir)
    begin
      data = File.read(path)
      @todos = List.parse(data)
    rescue
      STDERR.puts "Not found #{path}. Create it."
      File.open(path, "a") { }
      @todos = Array(::Todo::Todo).new
    end
    self
  end

  def <<(todo : ::Todo::Todo)
    @todos << todo
  end

  def [](id : Int32)
    @todos[id]
  end

  def rm(id : Int32)
    @todos.delete_at id rescue nil
  end

  def self.parse(s : String)
    s.split("\n").map { |l| ::Todo::Todo.new(l) }
  end
end
