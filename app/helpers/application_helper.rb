module ApplicationHelper
  include Pagy::Frontend

  CONTACT_TYPE = {
    tech: 'TechDomainContact',
    admin: 'AdminDomainContact',
  }.freeze

  def currency(amount)
    amount ||= 0
    format('%01.2f', amount.round(2)).sub(/\./, ',')
  end

  def login_with_role(user, registrar: true)
    value = "#{user.username} (#{user.role})"
    value += " - #{user.registrar_name}" if registrar
    value
  end

  def back_link
    link_to :back, class: 'back-link' do
      out = []
      out << tag.i(nil, class: 'fas fa-arrow-left')
      out << tag.span(t(:back))
      safe_join(out)
    end
  end

  def toggle_filter
    button_tag(data: { toggle: 'filters' }, type: '', class: 'button button--toggle') do
      out = []
      out << tag.span(t(:open_filter))
      out << tag.span(t(:close_filter))
      out << tag.i(nil, class: 'fas fa-filter')
      safe_join(out)
    end
  end

  def pretty_date(datetime)
    # 20.08.2017 kell 08:23
    datetime.strftime("%d.%m.%Y #{t('at')} %H:%M")
  end

  def icon_link_to(cls, url, html_options = {})
    link_to(url, html_options) do
      tag.i(nil, class: cls)
    end
  end

  def dynamic_select_tag(method, choices, options = {})
    options[:itemSelectText] ||= t(:press_to_select)
    options[:noChoicesText] ||= t(:start_typing)
    options[:allowHTML] = true
    select_tag(method, choices, options)
  end

  def simple_select_tag(method, choices, options = {})
    options[:itemSelectText] ||= t(:press_to_select)
    options[:allowHTML] = true
    select_tag(method, choices, options)
  end

  def tooltip(text)
    return if text.blank?

    tag.div(class: 'tooltip', data: { 'tippy-content': text }) do
      tag.i(nil, class: 'fas fa-question')
    end
  end

  def legal_document_types
    legal_doc_types = Rails.configuration.customization[:legal_document_types].split(',').map(&:strip)
    legal_doc_types.delete('ddoc')
    ".#{legal_doc_types.join(',.')}"
  end

  def csr_types
    types = Rails.configuration.customization[:csr_types].split(',').map(&:strip)
    ".#{types.join(',.')}"
  end

  def ident_for(contact)
    ident = contact[:ident]
    description = "[#{ident[:country_code]} #{ident[:type]}]"
    description.prepend("#{ident[:code]} ") if ident[:code].present?

    description
  end

  def sort_link(url, attribute, *args)
    s = SortLink.new(url, attribute, args, params)
    link_to(s.name, url(url, s.url_options), s.html_options(args))
  end

  def url(routing_proxy, options_for_url)
    if routing_proxy && respond_to?(routing_proxy)
      send(routing_proxy).url_for(options_for_url)
    else
      url_for(options_for_url)
    end
  end
end
