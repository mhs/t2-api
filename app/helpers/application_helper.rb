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

  def default_application_url
    default_app = T2Application.where(title: 'Utilization').first || T2Application.first
    add_query_param(default_app.url, "authentication_token", current_user.authentication_token)
  end
end
