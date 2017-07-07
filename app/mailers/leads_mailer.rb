class LeadsMailer < ActionMailer::Base
  default from: "no-reply@zenmaid.com"
  
  def notify_of_lead_capture(lead)
    @lead = lead
    mail(:to => "amar@zenmaid.com", :cc => "arun@zenmaid.com", :subject => "[ZenMaid] You have a new signup!")
  end

  def notify_of_onboarding_completion(user)
    @user = user
    @user_profile = user.user_profile
    mail(:to => "amar@zenmaid.com", :cc => "arun@zenmaid.com", :subject => "[ZenMaid] #{@user_profile.company_name} Onboarding Report")
  end

  def notify_of_exit_survey(user)
    @user = user
    @user_profile = user.user_profile
    mail(:to => "amar@zenmaid.com", :cc => "arun@zenmaid.com", :subject => "[ZenMaid] #{@user_profile.company_name} Exit Survey")
  end
end
