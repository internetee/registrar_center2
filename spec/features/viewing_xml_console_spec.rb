require 'rails_helper'

RSpec.feature 'viewing xml console' do
  include_context 'Common context with valid login'

  scenario 'with making poll request' do
    visit xml_console_path

    click_link('Poll req')
    console_contents = find('#payload').value
    expect(console_contents).to eq('')
  end
end
