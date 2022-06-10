module ApplicationHelper
  include Pagy::Frontend

  CONTACT_TYPE = {
    tech: 'TechDomainContact',
    admin: 'AdminDomainContact',
  }.freeze

  if Rails.configuration.customization[:legal_document_types].present?
    LEGAL_DOC_TYPES = Rails.configuration.customization[:legal_document_types].split(',').map(&:strip)
  else
    LEGAL_DOC_TYPES = %w[pdf asice asics sce scs adoc edoc bdoc ddoc zip rar gz tar 7z odt
                         doc docx].freeze
  end

  def app_form_with(model: nil, scope: nil, url: nil, format: nil, **options, &block)
    options = options.reverse_merge(builder: AppFormBuilder)
    form_with(model: model, scope: scope, url: url, format: format, **options, &block)
  end

  def currency(amount)
    amount ||= 0
    format('%01.2f', amount.round(2)).sub(/\./, ',')
  end

  def login_with_role(user)
    "#{user.username} (#{user.role}) - #{user.registrar_name}"
  end

  def back_link
    link_to :back, class: 'back-link' do
      html = "<i class='fas fa-arrow-left'></i>"
      html += "<span>#{t(:back)}</span>"
      html.html_safe
    end
  end

  def toggle_filter
    button_tag(data: { toggle: 'filters' }, type: '', class: 'button button--toggle') do
      html = "<span>#{t(:open_filter)}</span>"
      html += "<span>#{t(:close_filter)}</span>"
      html += '<i class="fas fa-filter"></i>'
      html.html_safe
    end
  end

  def pretty_date(datetime)
    # 20.08.2017 kell 08:23
    datetime.strftime("%d.%m.%Y #{t('at')} %H:%M")
  end

  def icon_link_to(cls, url, html_options = {})
    link_to(url, html_options) do
      content_tag(:i, nil, class: cls)
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
    return unless text.present?

    content_tag :div, class: 'tooltip',
                      data: { 'tippy-content': text } do
      html = <<-HTML
        <i class="fas fa-question"></i>
      HTML
      html.html_safe
    end
  end

  def legal_document_types
    types = LEGAL_DOC_TYPES.dup
    types.delete('ddoc')
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
