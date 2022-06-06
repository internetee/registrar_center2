# Rewritten class SortLink from Ransack original form_helper file:
# https://github.com/activerecord-hackery/ransack/blob/main/lib/ransack/helpers/form_helper.rb

class SortLink
  def initialize(url, attribute, args, params)
    @url            = url
    @params         = parameters_hash(params)
    @field          = attribute.to_s
    @sort_fields    = extract_sort_fields_and_mutate_args!(args).compact
    @current_dir    = existing_sort_direction
    @label_text     = extract_label_and_mutate_args!(args)
    @options        = extract_options_and_mutate_args!(args)
    @default_order  = @options.delete :default_order
  end

  def up_arrow
    I18n.t '.up_arrow_html'
  end

  def down_arrow
    I18n.t '.down_arrow_html'
  end

  def default_arrow
    I18n.t '.default_arrow_html'
  end

  def name
    [ERB::Util.h(@label_text), order_indicator]
      .compact
      .join('&nbsp;'.freeze)
      .html_safe
  end

  def url_options
    @params.merge(
      @options.except(:class, :data, :host).merge(search: search_and_sort_params)
    )
  end

  def html_options(args)
    if args.empty?
      html_options = @options
    else
      html_options = extract_options_and_mutate_args!(args)
    end

    html_options.merge(
      class: [['sort_link'.freeze, @current_dir], html_options[:class]]
             .compact.join(' '.freeze)
    )
  end

  private

  def parameters_hash(params)
    if params.respond_to?(:to_unsafe_h)
      params.to_unsafe_h
    else
      params
    end
  end

  def extract_sort_fields_and_mutate_args!(args)
    return args.shift if args[0].is_a?(Array)

    [@field]
  end

  def existing_sort_direction(field = @field)
    return unless sort = detect_sort(@params[:search], field)

    sort.split(' ')[1]
  end

  def detect_sort(search_params, field)
    return unless search_params && search_params[:s]

    sort = search_params[:s].is_a?(String) ? [search_params[:s]] : search_params[:s]
    sort.find { |s| s.split(' ').include?(field) }
  end

  def extract_label_and_mutate_args!(args)
    return args.shift if args[0].is_a?(String)

    I18n.t("#{@params[:controller]}.#{@params[:action]}.#{@field}")
  end

  def extract_options_and_mutate_args!(args)
    return args.shift.with_indifferent_access if args[0].is_a?(Hash)

    {}
  end

  def search_and_sort_params
    search_params.merge(s: sort_params)
  end

  def search_params
    @params[:search].presence || {}
  end

  def sort_params
    sort_array = recursive_sort_params_build(@sort_fields)
    return sort_array[0] if sort_array.length == 1

    sort_array
  end

  def recursive_sort_params_build(fields)
    return [] if fields.empty?

    [parse_sort(fields[0])] + recursive_sort_params_build(fields.drop 1)
  end

  def parse_sort(field)
    attr_name, new_dir = field.to_s.split(/\s+/)
    if no_sort_direction_specified?(new_dir)
      new_dir = detect_previous_sort_direction_and_invert_it(attr_name)
    end
    "#{attr_name} #{new_dir}"
  end

  def no_sort_direction_specified?(dir = @current_dir)
    dir != 'asc'.freeze && dir != 'desc'.freeze
  end

  def detect_previous_sort_direction_and_invert_it(attr_name)
    if sort_dir = existing_sort_direction(attr_name)
      direction_text(sort_dir)
    else
      default_sort_order(attr_name) || 'asc'.freeze
    end
  end

  def default_sort_order(attr_name)
    return @default_order[attr_name] if Hash == @default_order

    @default_order
  end

  def direction_text(dir)
    return 'asc'.freeze if dir == 'desc'.freeze

    'desc'.freeze
  end

  def order_indicator
    return default_arrow if no_sort_direction_specified?

    if @current_dir == 'desc'.freeze
      up_arrow
    else
      down_arrow
    end
  end
end