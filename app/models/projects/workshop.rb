class Workshop < Project

  def rate_for(_)
    if rates.has_key?('fee')
      rates['fee']
    else
      0.0
    end
  end

end
