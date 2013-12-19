class User < ActiveRecord::Base
  devise :omniauthable, :token_authenticatable, :omniauth_providers => [:google_oauth2]
  attr_accessible :email, :name, :uid, :date_format, :office_id, :office, :provider, :t2_application_id
  belongs_to :office
  has_one :person, inverse_of: :user
  belongs_to :t2_application

  before_create :set_date_format_if_unset


  def self.find_for_google_oauth2(auth, signed_in_resource=nil)
    # try to find user by auth info
    user = User.where(provider: auth.provider, uid: auth.uid).first

    unless user
      # if no user with auth info try to find one with same email
      email = auth.extra.raw_info.email.downcase
      if user = User.where(email: email).first
        user.update_attributes( name: auth.extra.raw_info.name,
                                email: email,
                                provider: auth.provider,
                                uid: auth.uid
                              )
      # no user record so create a new one
      elsif auth.extra.raw_info.email.match(/neo\.com$/)
        user = User.create( name: auth.extra.raw_info.name,
                            email: auth.extra.raw_info.email,
                            provider: auth.provider,
                            uid: auth.uid
                          )
      end
    end
    user.ensure_authentication_token! if user

    user
  end

  def clear_authentication_token!
    self.authentication_token = nil
    self.save
  end

  def long_date_format
    month_first? ? :month_first_long : :day_first_long
  end

  def short_date_format
    month_first? ? :month_first_short : :day_first_short
  end

  def date_formats
    [
      {key: :month_first, value: "Month First"},
      {key: :day_first, value: "Day First"}
    ]
  end

  private
  def month_first?
    date_format == 'month_first'
  end

  def set_date_format_if_unset
    self.date_format ||= 'month_first'
  end
end

