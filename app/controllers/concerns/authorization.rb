# app/controllers/concerns/authorization.rb
module Authorization
  extend ActiveSupport::Concern

  included do
    helper_method :can?
  end

  def can?(action, subject)
    abilities = current_user.abilities.with_indifferent_access
    return false if abilities[:can].blank?
    return false if abilities[:can][action].blank?

    abilities[:can][action].keys.include? subject
  end

  def authorize!(action, subject)
    return if can? action, subject

    respond_to do |format|
      format.html { redirect_to dashboard_url, alert: 'Authorization error' }
    end
  end
end
