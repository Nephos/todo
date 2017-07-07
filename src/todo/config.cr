require "yaml"
require "yaml"

class Todo::Config
  FILE_PATH = File.expand_path ".config/todorc", ENV["HOME"]

  YAML.mapping(
    hooks: Hash(String, Array(String)?)?,
  )

  def self.new
    File.open FILE_PATH, "a" { }
    Config.from_yaml(File.read(FILE_PATH)) rescue Config.empty
  end

  def self.empty
    Config.from_yaml("{}")
  end

  def exec(hook_name : String, *args)
    hooks = self.hooks
    unless hooks.nil?
      current = (hooks[hook_name]?)
      exec_hooks(current, *args) unless (current.nil?)
    end
  end

  private def exec_hooks(hooks : Array(String), *args)
    hooks.each do |hook|
      args_str = args.map { |e| "#{e.to_s.inspect}" }.join(" ")
      d = `#{hook} #{args_str}`.strip
      puts d unless d.empty?
    end
  end
end
