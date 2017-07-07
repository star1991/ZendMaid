class LeadsController < ApplicationController

  layout 'application-sign-in'

  def new
    @lead = Lead.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @lead }
    end
  end
  
  def create
    @lead = Lead.new(params[:lead])

    respond_to do |format|
      if @lead.save
        LeadsMailer.notify_of_lead_capture(@lead).deliver
        format.html { redirect_to thank_you_path }
      else
        format.html { render action: "new" }
      end
    end
  end

  def launch
    @lead = Lead.new
  end

  def sales_letter

  end

  def sign_up

    @lead = Lead.new(params[:lead])

    respond_to do |format|

    if @lead.save
      LeadsMailer.notify_of_lead_capture(@lead).deliver
      format.js { render 'leads/sign_up_success' }
    else
      flash.now[:error] = "Oops! Something went wrong during the sign up process. Please review the errors below!"

      format.js { render 'leads/sign_up_error' }
    end

    end
  end
  
  def thank_you

  end

end
