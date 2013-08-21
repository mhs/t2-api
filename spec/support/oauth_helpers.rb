module OauthHelpers
  def mock_login(user)
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
      :provider => user.provider,
      :uid => user.uid
    })
  end
end
