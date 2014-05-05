class Reports::Base

  def self.column_names
    raise NotImplementedError
  end

  def to_csv_string
    raise NotImplementedError
  end

end
