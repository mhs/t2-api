class UserMailer < ActionMailer::Base
  layout 'mailer'

  def allocation_upcoming_email(email)
    @creator = User.find_by(email: "#{email}")
    @allocations = @creator.created_allocations.starting_soon.provisional

    mail(to: @creator.email, subject: 'You have one or more provisional projects/allocations in T2 that are due to start in the next two days or have already started. Please adjust to reflect your current understanding of the project(s).')
  end
end
