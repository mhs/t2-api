class Date
  def following_monday
    (self + 2.days).monday
  end

  def preceding_friday
    following_monday - 3.days
  end

  def weekend?
    saturday? || sunday?
  end
end
