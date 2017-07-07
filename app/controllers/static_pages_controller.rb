class StaticPagesController < ApplicationController
  layout 'application-landing', :only => [:home]
  
  def home
  end
  
  def about
  end

  def help
  end
  
  def contact
  end
  
  def terms
  end
end
