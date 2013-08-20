class CookieMonster
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)

    # this will remove just your session cookie
    if env['PATH_INFO'].match(/^\/api/)
      Rack::Utils.delete_cookie_header!(headers, '_t2-api_session')
    end

    [status, headers, body]
  end
end

Rails.application.config.middleware.insert_before ::ActionDispatch::Cookies, ::CookieMonster
Rails.backtrace_cleaner.add_silencer { |line| line.start_with? "lib/cookie_monster.rb" }

