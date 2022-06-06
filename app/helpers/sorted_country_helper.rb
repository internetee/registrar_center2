module SortedCountryHelper
  QUICK_LIST = %w[EE FI LV LT RU SE US].freeze

  def all_country_options(selected = nil)
    quick_options = options_for_select(quick_list, selected: selected)

    # no double select
    selected = quick_list.map(&:second).include?(selected) ? '' : selected

    all_options = options_for_select([['---', '---']] + all_sorted(truncate: true),
                                     selected: selected, disabled: ['---'])
    quick_options + all_options
  end

  def quick_list
    list = [[I18n.t(:choose), '']]
    list + Country.all.select { |c| QUICK_LIST.include?(c.alpha2) }.map do |c|
      [c.translations[I18n.locale], c.alpha2]
    end
  end

  def all_sorted(truncate: false)
    translated_countries = []
    Country.all.each do |c|
      name = c.translations[I18n.locale]
      name.truncate(26) if truncate
      translated_countries << [name, c.alpha2]
    end
    translated_countries.sort { |c1, c2| c1[0] <=> c2[0] }
  end
end