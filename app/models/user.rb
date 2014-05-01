class User < ActiveRecord::Base
  devise :omniauthable, :omniauth_providers => [:google_oauth2]
  attr_accessible :email, :name, :uid, :date_format, :office_id, :office, :provider, :t2_application_id
  belongs_to :office
  has_one :person, inverse_of: :user
  belongs_to :t2_application
  has_many :created_allocations, class_name: 'Allocation', :foreign_key => 'creator_id'

  before_create :set_date_format_if_unset

  NO_PERSON_NAME = "Temp User"
  NO_PERSON_OFFICE = 9 

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
      else
        # GTFO
      end
    end
    user.ensure_authentication_token! if user

    user
  end

  def ensure_authentication_token!
    return unless authentication_token.blank?
    self.authentication_token = generate_authentication_token
    save!
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

  def set_person
    if self.person
       self.person
    else
       Person.new(name: NO_PERSON_NAME, office_id: self.office_id ? self.office_id : NO_PERSON_OFFICE)
    end
  end

  private
  def month_first?
    date_format == 'month_first'
  end

  def set_date_format_if_unset
    self.date_format ||= 'month_first'
  end

  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).exists?
    end
  end

end

