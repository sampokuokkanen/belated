class DumDum
  def initialize(sleep: 0)
    @sleep = sleep
  end

  def perform
    sleep(@sleep)
    5 / 4
  end
end

class DumDumArgs < DumDum
  def perform(arg = 'hello')
    arg
  end
end

class DumDumKwargs < DumDum
  def perform(dum_key: 'world')
    dum_key
  end
end
