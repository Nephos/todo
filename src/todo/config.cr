require "yaml"
require "json"

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

  def exec(hook_name : String)
    hooks = self.hooks
    unless hooks.nil?
      current = hooks[hook_name]?
      unless current.nil?
        current.each { |hook| d = `#{hook}`.strip; puts d unless d.empty? }
      end
    end
  end
end
