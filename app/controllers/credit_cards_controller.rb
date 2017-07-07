class CreditCardsController < ApplicationController

	before_filter :authenticate_user!

	def process_card
		@credit_card = CreditCard.new(params[:credit_card])
		@customer = current_user.customers.find(params[:customer_id])

		charge = @credit_card.charge
		if @credit_card.token.present?
			@credit_card = @customer.credit_cards.find_by_token(@credit_card.token)
			@credit_card.charge = charge
		else
			@credit_card.customer_id = @customer.id

			# Registers charge and attaches it to customer object
			@credit_card.register_card(current_user.payment_gateway, @customer)

			if @credit_card.card_number.present?
				@credit_card.masked_card_number = 'X'*(@credit_card.card_number.length-4) + @credit_card.card_number[@credit_card.card_number.length-4..@credit_card.card_number.length]
			end
		end

		respond_to do |format|
			# Cache whether the card is a new record or not for use in views (if successful save, dirty state is not retained)
			@credit_card_new = @credit_card.new_record?

			# Existing records are also saved at this step to create validations on charge
			if @credit_card.save && (charge.blank? || @credit_card.process_charge(current_user.payment_gateway, charge))

				if params[:appointment_id].present? && charge.present?
					current_user.appointments.find(params[:appointment_id]).update_column(:paid, true)
				end
			
				format.js { render 'credit_cards/process_success' }
			else
				logger.debug @credit_card.errors[:base]
				flash.now[:error] = "Oops! Something went wrong when saving your changes. Please review the errors below!"

				format.js { render 'customers/manage_credit_cards' }
			end

		end
	end

	def destroy
		@credit_card = current_user.credit_cards.find(params[:id])
		@credit_card.destroy

		respond_to do |format|
			format.js
		end
	end
end
