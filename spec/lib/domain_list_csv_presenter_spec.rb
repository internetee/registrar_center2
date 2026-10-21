require 'rails_helper'

RSpec.describe DomainListCsvPresenter do
  let(:view) { ApplicationController.new.view_context }
  let(:domain) do
    { name: 'example.ee', transfer_code: 'transfer-code', registrant: { name: 'Registrant', code: 'contact-id' },
      expire_time: '2028-03-01T00:00:00+02:00', statuses: {} }
  end

  [true, false, nil].each do |enabled|
    it "exports the automatic renewal preference #{enabled.inspect} as a numeric flag" do
      domain[:auto_renew] = { enabled: enabled } unless enabled.nil?
      csv = CSV.parse(described_class.new(objects: [domain], view: view).to_s, headers: true)

      expect(csv.headers.last).to eq(I18n.t('domains.index.csv.auto_renew'))
      expect(csv.first[-1]).to eq(enabled ? '1' : '0')
      expect(csv.first[0]).to eq(domain[:name])
    end
  end
end
