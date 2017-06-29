require "yaml"

class Todo::Todo
  YAML.mapping(
    msg: {type: String},
    date: {type: String, setter: false},
  )

  DATE_FORMAT = "%y/%m/%d"
  DATE_SEP    = "(?:[/\-])"
  # DATE_MATCH_1 = Regex.new "(?:(\d+)#{DATE_SEP})?(?:(\d+)#{DATE_SEP})(?:(\d+))"
  DATE_MATCH_1 = /^(?:(\d+)#{DATE_SEP})?(\d+)#{DATE_SEP}(\d+)$/
  DATE_MATCH_2 = /^d\+(\d+)$/i

  def date=(value : String)
    @date = if value.empty?
              value
            elsif m = value.match DATE_MATCH_1
              year = (m[1]? || Time.now.year - 2000).to_i
              "#{year}/#{m[2]}/#{m[3]}"
            elsif m = value.match DATE_MATCH_2
              (Time.now + m[1].to_i.days).to_s(DATE_FORMAT)
            else
              STDERR.puts "[WARN] \"#{value}\" is not a valid date"
              value
            end
    @date
  end

  def initialize(msg : String, date : String?)
    @msg = ""
    @date = ""
    self.msg = msg
    self.date = date
  end

  def initialize(s : String)
    @msg = ""
    @date = ""
    data = s.split(SEP)
    self.msg = data[0]
    self.date = data[1]
  end
end
