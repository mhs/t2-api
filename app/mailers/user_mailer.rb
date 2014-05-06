class UserMailer < ActionMailer::Base
  layout 'allocation_mailer'

  def allocation_upcoming_email(email)
    @creator = User.find_by(email: "#{email}")
    @allocations = @creator.created_allocations.starting_soon.provisional

    mail(to: @creator.email, subject: 'Upcoming provisional T2 allocations that need your attention.')
  end
end
