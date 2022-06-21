class DashboardController < BaseController
  MAX_CONTACTS = 20
  def index
    result = ApiConnector::SummaryInfoChecker.call(**auth_info)
    handle_response(result); return if performed?

    @balance = @response.balance
    @max_contacts = MAX_CONTACTS
    @domains_count = @response.domains
    @contacts_count = @response.contacts
    @notification = @response.notification
    @notifications_count = @response.notifications_count
  end
end
