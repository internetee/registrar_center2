require 'rails_helper'

RSpec.feature 'domain automatic renewal' do
  include_context 'Common context with valid login'

  let(:base_url) { "#{ENV['REPP_HOST']}#{ENV['REPP_ENDPOINT']}" }
  let(:cycle) do
    { id: 'displayed-cycle', state: 'autoRenewPeriod', original_expire_time: '2027-03-01T00:00:00+02:00',
      expire_time: '2028-03-01T00:00:00+02:00', cancellation_deadline: '2027-03-16T00:00:00+02:00', attempts: 1 }
  end
  let(:domain) do
    { name: 'example.ee', transfer_code: 'transfer-code', registrant: { code: 'contact-id', name: 'Registrant' },
      created_at: '2026-03-01T00:00:00+02:00', updated_at: '2027-03-01T00:00:00+02:00',
      expire_time: cycle[:expire_time], statuses: {}, contacts: [], nameservers: [], dnssec_keys: [],
      auto_renew: { enabled: true, cycle: cycle } }
  end

  def stub_repp(method, path, data, status: 200, code: 1000, message: 'Command completed successfully')
    stub_request(method, "#{base_url}#{path}")
      .to_return(status: status, headers: { 'Content-Type' => 'application/json' },
                 body: { code: code, message: message, data: data }.to_json)
  end

  before do
    VCR.eject_cassette
    stub_repp(:get, '/domains/example.ee?locale=en', { domain: domain })
  end

  after { VCR.eject_cassette }

  scenario 'create defaults to unchecked and edit hydrates the registry preference' do
    visit new_domain_path
    expect(page).to have_unchecked_field('Automatic renewal')

    visit edit_domain_path(domain_name: domain[:name])
    expect(page).to have_checked_field('Automatic renewal')
    expect(page).to have_content('Disabling this preference only stops future renewals')
  end

  scenario 'unchecking edit sends false through the dedicated endpoint' do
    full_update = stub_repp(:put, '/domains/example.ee', { domain: domain }).with do |req|
      !JSON.parse(req.body).fetch('domain').key?('auto_renew')
    end
    preference = stub_repp(:put, '/domains/example.ee/auto_renew',
                          { domain: domain[:name], auto_renew: { enabled: false, cycle: cycle } }).with do |req|
      JSON.parse(req.body).fetch('auto_renew') == { 'enabled' => false }
    end

    visit edit_domain_path(domain_name: domain[:name])
    uncheck 'Automatic renewal'
    click_button 'Save'

    expect(page).to have_current_path(domain_path(domain_name: domain[:name]))
    expect(page).to have_content('Command completed successfully')
    expect(full_update).to have_been_requested.once
    expect(preference).to have_been_requested.once
  end

  scenario 'details show the cycle and a confirmed refund form with the displayed cycle ID' do
    visit domain_path(domain_name: domain[:name])

    expect(page).to have_content('Enabled')
    expect(page).to have_content('Automatic renewal grace period')
    expect(page).to have_content('Original expiry')
    expect(page).to have_content('New expiry')
    expect(page).to have_content('Cancellation deadline')
    expect(page).to have_content(cycle[:id])
    form = find_button('Cancel automatic renewal and refund').find(:xpath, 'ancestor::form')
    expect(form['data-turbo-confirm']).to include('refund its charge')
    expect(form).to have_css('input[name="auto_renew[enabled]"][value="false"]', visible: :all)
    expect(form).to have_css('input[name="auto_renew[cycle_id]"][value="displayed-cycle"]', visible: :all)
  end

  scenario 'refund submits the displayed cycle ID and shows the command result' do
    refund = stub_repp(:put, '/domains/example.ee/auto_renew', { domain: domain[:name] },
                      message: 'Renewal reversed and refunded').with do |req|
      JSON.parse(req.body).fetch('auto_renew') == { 'enabled' => 'false', 'cycle_id' => cycle[:id] }
    end

    visit domain_path(domain_name: domain[:name])
    click_button 'Cancel automatic renewal and refund'

    expect(page).to have_content('Renewal reversed and refunded')
    expect(refund).to have_been_requested.once
  end

  scenario 'a stale grace page displays a registry deadline error' do
    stub_repp(:put, '/domains/example.ee/auto_renew', {}, status: 400, code: 2304,
              message: 'Cancellation deadline passed')

    visit domain_path(domain_name: domain[:name])
    click_button 'Cancel automatic renewal and refund'

    expect(page).to have_content('Cancellation deadline passed')
  end

  %w[fundingRetry completed failed reversed cancelled].each do |state|
    scenario "details label #{state} without offering a refund" do
      cycle[:state] = state
      stub_repp(:get, '/domains/example.ee?locale=en', { domain: domain })

      visit domain_path(domain_name: domain[:name])

      expect(page).to have_content(I18n.t("auto_renew.states.#{state}"))
      expect(page).not_to have_button('Cancel automatic renewal and refund')
    end
  end

  scenario 'portfolio shows automatic renewal and forwards selected filters' do
    stub_repp(:get, "/domains?details=true&simple=true&limit=#{Pagy::DEFAULT[:items]}&offset=0&q&locale=en",
              { statuses: [], domains: [domain], count: 1, new_domain: [] })
    filtered = stub_request(:get, "#{base_url}/domains")
               .with(query: hash_including('q' => { 'auto_renew_eq' => 'true', 'auto_renew_grace' => 'true',
                                                  'auto_renew_funding_retry' => 'true' }))
               .to_return(status: 200, headers: { 'Content-Type' => 'application/json' },
                          body: { code: 1000, data: { statuses: [], domains: [domain], count: 1, new_domain: [] } }.to_json)

    visit domains_path
    expect(page).to have_content('Automatic renewal grace period')
    check 'Automatic renewal enabled'
    check 'In automatic renewal grace period'
    check 'Automatic renewal awaiting funding or retry'
    click_button 'Filter'

    expect(filtered).to have_been_requested.once
    expect(page).to have_checked_field('Automatic renewal enabled')
  end

  scenario 'dashboard renders structured automatic renewal notifications' do
    notification = { id: 1, text: 'Renewal notice', created_at: '2027-03-01T00:00:00+02:00',
                     attached_obj_type: 'DomainAutoRenewal',
                     attached_obj_data: { event: 'renewed', domain: domain[:name], cycle: cycle } }
    stub_repp(:get, '/registrar/summary?locale=en',
              { balance: { amount: '100.00', currency: 'EUR' }, domains: 1, contacts: 1,
                notifications_count: 1, notification: notification })

    visit dashboard_path

    expect(page).to have_content('Domain automatically renewed')
    expect(page).to have_content(domain[:name])
    expect(page).to have_content(cycle[:id])
    expect(page).to have_content('Cancellation deadline')
    expect(page).to have_content('Renewal attempts')
  end

  {
    en: 'Domain not renewed by the cancellation deadline. Automatic renewal attempts for this expiry have stopped; the preference remains enabled.',
    et: 'Domeeni ei pikendatud tühistamise tähtajaks. Selle aegumisega seotud automaatse pikendamise katsed on lõppenud; automaatse pikendamise valik jääb lubatuks.'
  }.each do |locale, message|
    scenario "dashboard renders a failed renewal with attempts stopped in #{locale}" do
      cycle[:state] = 'failed'
      cycle[:expire_time] = nil
      notification = { id: 1, text: 'Renewal notice', created_at: '2027-03-16T00:00:00+02:00',
                       attached_obj_type: 'DomainAutoRenewal',
                       attached_obj_data: { event: 'renewalFailed', domain: domain[:name], cycle: cycle } }
      stub_repp(:get, "/registrar/summary?locale=#{locale}",
                { balance: { amount: '100.00', currency: 'EUR' }, domains: 1, contacts: 1,
                  notifications_count: 1, notification: notification })

      visit dashboard_path(locale: locale)

      expect(page).to have_content(message)
      expect(page).to have_content(domain[:name])
      expect(page).to have_content(cycle[:id])
      expect(page).to have_content(I18n.t('auto_renew.states.failed', locale: locale, raise: true))
      expect(page).to have_content(I18n.t('auto_renew.cancellation_deadline', locale: locale, raise: true))
      expect(page).to have_content(I18n.t('auto_renew.attempts', locale: locale, raise: true))
      expect(page).not_to have_content(I18n.t('auto_renew.expire_time', locale: locale, raise: true))
    end
  end
end
