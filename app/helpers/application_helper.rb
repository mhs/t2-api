module ApplicationHelper

  def add_query_param(url, key, value)
    # Holy fuck
    url = URI.parse(url)
    param = [[key, value]]
    url.query = URI.encode_www_form(URI.decode_www_form(url.query || "") + param)
    url.to_s
  end

  # TODO: torch these when the old navbar code goes away
  def t2_applications
    T2Application.order('position ASC').to_a.reject { |app| app.title.downcase == "settings" }
  end

  def default_application
    T2Application.find_by_id(current_user.t2_application_id) || T2Application.order(:position).first
  end

  def settings_app_url
    settings_app = T2Application.where(title: 'Settings').first
    settings_app_url = settings_app ? settings_app.url : "#"
    add_query_param(settings_app_url, "authentication_token", current_user.authentication_token)
  end
end
