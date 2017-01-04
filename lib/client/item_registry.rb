class ItemRegistry
  def parse(string)
    case string
      when "a soda can"; :soda
      when "an old newspaper"; :newspaper
      when "a pair of old brown flipflops"; :flip
      when "a shard of broken glass"; :shard
      else nil
    end
  end
end