class ItemRegistry
  def parse(string)
    case string
      when "a soda can"; :can
      when "an old newspaper"; :newspaper
      when "a pair of old brown flipflops"; :flipflops
      when "a shard of broken glass"; :shard
      when "a Survival Guide for you to EXAMINE"; :guide
      else
        # TODO use Stanford parser online to get root word
        string.split.last.to_sym
    end
  end
end
