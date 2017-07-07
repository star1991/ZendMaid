module UsersHelper
  
  def current_user?(user)
    current_user == user
  end
  
  def get_plan_name(plan_id)
    plan_num = plan_id.to_i
    
    case
    when plan_num <= 50
      "Appointment Only"
    when plan_num > 50 && plan_num <= 150
      "Small Business"
    else
      "Enterprise"
    end      
      
  end

  def plan_id_to_name(user)
    plan_id = user.plan_id

    case 
    when plan_id == 'premium-new'
      "Premium (Month-to-Month, $99/mo)"
    when plan_id == 'basic-new'
      "Basic (Month-to-Month, $49/mo)"
    when plan_id == 'premium-annual'
      "Premium (Paid Annually - $59/mo)"
    when plan_id == 'basic-annual'
      "Basic (Paid Annually - $29/mo)"
    when plan_id == 'premium-one-time'
      "Premium (One-Time Fee, $1,497)"
    when plan_id == 'novlaunch'
      "Premium (Month-to-Month, $99/mo)"
    when plan_id == 'systems-week-launch'
      "Systems Week Discount ($79/mo)"
    when plan_id == 'premium-1997'
      "Premium (One-Time Fee, $1,997)"
    else
      plan_id
    end

  end
end
