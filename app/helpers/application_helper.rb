module ApplicationHelper

  def add_query_param(url, key, value)
    # Holy fuck
    url = URI.parse(url)
    param = [[key, value]]
    url.query = URI.encode_www_form(URI.decode_www_form(url.query || "") + param)
    url.to_s
  end

  def t2_applications
    T2Application.order('position ASC').all
  end

  def default_application
    T2Application.where(title: 'Utilization').first || T2Application.first
  end
end
