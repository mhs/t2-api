class Navbar
  attr_accessor :top, :bottom

  def initialize(applications)
    self.top, self.bottom = applications.partition { |app| app.title.downcase != "settings" }
  end

  def active_model_serializer
    NavbarSerializer
  end
end
