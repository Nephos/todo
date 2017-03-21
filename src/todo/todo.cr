class Todo
  SEP = Char::ZERO

  property msg : String
  property date : String

  def initialize(@msg, @date = "")
  end

  def initialize(s : String)
    data = s.split(SEP)
    @msg = data[0]
    @date = data[1]
  end

  def to_s
    "#{msg}#{SEP}#{date}"
  end
end
