class DumDum
  def initialize(sleep: 0)
    @sleep = sleep
  end

  def perform
    sleep(@sleep)
    5 / 4
  end
end
