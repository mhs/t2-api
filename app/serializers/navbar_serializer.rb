class NavbarSerializer < ActiveModel::Serializer
  attributes :url, :title, :link_text, :icon

  def url
    # add current_user's access token to the base URL
    add_query_param(object.url, "authentication_token", current_user.authentication_token)
  end

  def link_text
    object.title.downcase
  end

  private

  def add_query_param(url, key, value)
    url = URI.parse(url)
    param = [[key, value]]
    url.query = URI.encode_www_form(URI.decode_www_form(url.query || "") + param)
    url.to_s
  end

end
