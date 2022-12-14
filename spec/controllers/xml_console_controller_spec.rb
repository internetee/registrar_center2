require 'rails_helper'

RSpec.describe XmlConsoleController, type: :controller do
  options = [
    {
      method: :load,
      http_method: :get,
      params: {
        obj: 'poll',
        epp_action: 'poll',
      },
    },
    {
      method: :create,
      http_method: :post,
      params: {
        payload: '<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>\n' \
                 '<epp xmlns=\"https://epp.tld.ee/schema/epp-ee-1.0.xsd\">\n' \
                 '<command>\n<poll op=\"req\"/>\n' \
                 '<clTRID>maricavor-1670582159</clTRID>\n' \
                 ' </command>\n</epp>\n", "xml_console"=>{"payload"=>"<?xml version=\"1.0\" ' \
                 'encoding=\"UTF-8\" standalone=\"no\"?>\n' \
                 '<epp xmlns=\"https://epp.tld.ee/schema/epp-ee-1.0.xsd\">\n' \
                 '<command>\n    <poll op=\"req\"/>\n    <clTRID>maricavor-1670582159</clTRID>\n' \
                 '</command>\n</epp>\n',
      },
    },
  ]

  it_behaves_like 'Base controller with auth', options
end