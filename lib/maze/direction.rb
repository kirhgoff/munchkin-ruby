class Direction
  ALL = [:south, :north, :east, :west]
  ALL_S = ALL.map(&:to_s)

  def self.all
    ALL
  end

  def self.all_s
    ALL_S
  end

  def self.parse(string)
    if string.nil? || string.empty?
      nil
    else
      string = string.downcase
      symbol = ALL_S.find { |dir| dir.start_with?(string) }
      symbol.nil? ? nil : symbol.intern
    end
  end

end
