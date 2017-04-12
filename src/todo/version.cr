require "yaml"

module Todo
  VERSION = YAML.parse({{ system("cat", "shard.yml").stringify }})["version"]
end
