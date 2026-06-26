# frozen_string_literal: true

require "rails_helper"

RSpec.describe VoogFooterHelper, type: :helper do
  describe "#footer_link_url" do
    it "returns the i18n fallback URL when Voog fetching is disabled" do
      allow(VoogFooter).to receive(:configuration).and_return(
        instance_double(VoogFooter::Configuration, enabled: false, site_url: "https://www.internet.ee")
      )

      expect(helper.footer_link_url(:faq)).to eq("https://www.internet.ee/help-and-info/faq")
    end

    it "resolves footer slots via FOOTER_LINK_VOOG_KEYS" do
      allow(VoogFooter).to receive(:configuration).and_return(
        instance_double(VoogFooter::Configuration, enabled: true, site_url: "https://www.internet.ee")
      )
      allow(VoogFooter).to receive(:structure).and_return(
        "en" => {
          "columns" => [
            {
              "links" => [
                {
                  "key" => "ee_domain_regulation",
                  "url" => "https://www.internet.ee/domains/ee-domain-regulation",
                  "text" => "Regulation"
                }
              ],
              "social_links" => []
            }
          ]
        }
      )

      expect(helper.footer_link_url(:domain_regulation)).to eq(
        "https://www.internet.ee/domains/ee-domain-regulation"
      )
    end

    it "prefers Voog URLs when structure is available" do
      allow(VoogFooter).to receive(:configuration).and_return(
        instance_double(VoogFooter::Configuration, enabled: true, site_url: "https://www.internet.ee")
      )
      allow(VoogFooter).to receive(:structure).and_return(
        "en" => {
          "columns" => [
            {
              "links" => [
                { "key" => "faq", "url" => "https://www.internet.ee/en/faq", "text" => "FAQ" }
              ],
              "social_links" => []
            }
          ]
        }
      )

      expect(helper.footer_link_url(:faq)).to eq("https://www.internet.ee/en/faq")
    end

    it "returns the cookie settings URL from i18n" do
      allow(VoogFooter).to receive(:configuration).and_return(
        instance_double(VoogFooter::Configuration, enabled: false, site_url: "https://www.internet.ee")
      )

      expect(helper.footer_link_url(:cookie_settings)).to eq("javascript:void(0)")
    end

    it "returns the cookie settings URL from i18n even when Voog has a policy link" do
      allow(VoogFooter).to receive(:configuration).and_return(
        instance_double(VoogFooter::Configuration, enabled: true, site_url: "https://www.internet.ee")
      )
      allow(VoogFooter).to receive(:structure).and_return(
        "en" => {
          "columns" => [
            {
              "links" => [
                { "key" => "cookie_settings", "url" => "https://voog.example/cookies", "text" => "Voog" }
              ],
              "social_links" => []
            }
          ]
        }
      )

      expect(helper.footer_link_url(:cookie_settings)).to eq("javascript:void(0)")
    end
  end

  describe "#footer_navigation_columns" do
    it "mirrors Voog column order, names, and link order when enabled" do
      allow(VoogFooter).to receive(:configuration).and_return(
        instance_double(VoogFooter::Configuration, enabled: true, site_url: "https://www.internet.ee")
      )
      allow(VoogFooter).to receive(:structure).and_return(
        "en" => {
          "columns" => [
            {
              "name" => "Help and info",
              "links" => [
                { "key" => "faq", "url" => "https://www.internet.ee/faq", "text" => "Voog FAQ" },
                { "key" => "statistics", "url" => "https://www.internet.ee/stats", "text" => "Stats" }
              ],
              "social_links" => []
            },
            {
              "name" => "Registrars",
              "links" => [
                {
                  "key" => "accredited_registrars",
                  "url" => "https://www.internet.ee/registrars",
                  "text" => "Registrars"
                }
              ],
              "social_links" => []
            },
            {
              "follow_us" => true,
              "name" => "Follow us!",
              "links" => [],
              "social_links" => [
                { "key" => "facebook", "url" => "https://www.facebook.com/page", "icon" => { "name" => "facebook" } }
              ]
            }
          ]
        }
      )

      columns = helper.footer_navigation_columns

      expect(columns.map { |c| c[:name] }).to eq(["Help and info", "Registrars"])
      expect(columns.first[:links].map { |l| l[:label] }).to eq(["FAQ", ".ee Statistics"])
      expect(columns.first[:links].map { |l| l[:key] }).not_to include(:cookie_settings)
      expect(columns.first[:links].first[:url]).to eq("https://www.internet.ee/faq")
    end

    it "renders cookie settings from the app with data-cc, not Voog markup" do
      allow(VoogFooter).to receive(:configuration).and_return(
        instance_double(VoogFooter::Configuration, enabled: true, site_url: "https://www.internet.ee")
      )
      allow(VoogFooter).to receive(:structure).and_return(
        "en" => {
          "columns" => [
            {
              "name" => "Help",
              "links" => [
                { "key" => "cookie_settings", "url" => "https://voog.example/cookies", "text" => "Voog Cookies" },
                {
                  "key" => "principles_for_the_content_management_of_estonian_internet",
                  "url" => "https://www.internet.ee/content",
                  "text" => "Content"
                },
                { "key" => "faq", "url" => "https://www.internet.ee/faq", "text" => "FAQ" }
              ],
              "social_links" => []
            }
          ]
        }
      )

      links = helper.footer_navigation_columns.first[:links]
      cookie = links.find { |l| l[:key] == :cookie_settings }

      expect(links.map { |l| l[:label] }).to eq(["Content Management", "Cookie Settings", "FAQ"])
      expect(cookie[:url]).to eq("javascript:void(0)")
      expect(cookie[:html_options]).to include(
        target: '_blank',
        rel: 'noopener',
        title: 'Cookie Settings',
        'data-cc': 'c-settings'
      )
    end

    it "uses static fallback columns when Voog is disabled" do
      allow(VoogFooter).to receive(:configuration).and_return(
        instance_double(VoogFooter::Configuration, enabled: false, site_url: "https://www.internet.ee")
      )

      columns = helper.footer_navigation_columns

      expect(columns.map { |c| c[:name] }).to eq(
        ["Help & info", "Registrars", "About us"]
      )
      expect(columns.first[:links].map { |l| l[:key] }).to eq(
        VoogFooterHelper::FOOTER_NAV_COLUMNS_FALLBACK.first[:links] + [:cookie_settings]
      )
      cookie = columns.first[:links].find { |l| l[:key] == :cookie_settings }
      expect(cookie[:html_options][:'data-cc'] || cookie[:html_options]['data-cc']).to eq('c-settings')
    end
  end

  describe "#footer_social_column_title" do
    it "uses the Voog social column name when enabled" do
      allow(VoogFooter).to receive(:configuration).and_return(
        instance_double(VoogFooter::Configuration, enabled: true, site_url: "https://www.internet.ee")
      )
      allow(VoogFooter).to receive(:structure).and_return(
        "en" => {
          "columns" => [
            {
              "follow_us" => true,
              "name" => "Follow us!",
              "social_links" => []
            }
          ]
        }
      )

      expect(helper.footer_social_column_title).to eq("Follow us!")
    end

    it "falls back to i18n when Voog is disabled" do
      allow(VoogFooter).to receive(:configuration).and_return(
        instance_double(VoogFooter::Configuration, enabled: false, site_url: "https://www.internet.ee")
      )

      expect(helper.footer_social_column_title).to eq("Social media")
    end
  end

  describe "#footer_social_links" do
    it "falls back to default social keys when Voog is disabled" do
      allow(VoogFooter).to receive(:configuration).and_return(
        instance_double(VoogFooter::Configuration, enabled: false, site_url: "https://www.internet.ee")
      )

      keys = helper.footer_social_links.map { |link| link[:key] }

      expect(keys).to eq(VoogFooterHelper::FOOTER_SOCIAL_KEYS)
      expect(helper.footer_social_links.first[:url]).to include("facebook.com")
    end

    it "maps Voog social links to brand icons by URL host when keys are path-derived" do
      allow(VoogFooter).to receive(:configuration).and_return(
        instance_double(VoogFooter::Configuration, enabled: true, site_url: "https://www.internet.ee")
      )
      allow(VoogFooter).to receive(:structure).and_return(
        "en" => {
          "columns" => [
            {
              "follow_us" => true,
              "social_links" => [
                {
                  "key" => "eestiinternet",
                  "url" => "https://www.facebook.com/EestiInternet",
                  "icon" => { "name" => nil }
                },
                {
                  "key" => "eesti_internet",
                  "url" => "https://twitter.com/Eesti_Internet",
                  "icon" => { "name" => nil }
                }
              ]
            }
          ]
        }
      )

      links = helper.footer_social_links

      expect(links.map { |l| l[:key] }).to eq(%i[facebook twitter])
      expect(links.first[:icon_class]).to eq("fab fa-facebook-square")
      expect(links.first[:url]).to include("facebook.com")
    end

    it "skips Voog social links without a key" do
      allow(VoogFooter).to receive(:configuration).and_return(
        instance_double(VoogFooter::Configuration, enabled: true, site_url: "https://www.internet.ee")
      )
      allow(VoogFooter).to receive(:structure).and_return(
        "en" => {
          "columns" => [
            {
              "follow_us" => true,
              "social_links" => [
                { "key" => "facebook", "url" => "https://www.facebook.com/page", "text" => "Facebook" },
                { "key" => nil, "url" => "https://example.com/unknown", "text" => "Unknown" }
              ]
            }
          ]
        }
      )

      keys = helper.footer_social_links.map { |link| link[:key] }

      expect(keys).to eq([:facebook])
    end
  end

  describe "#footer_link_label" do
    it "prefers i18n labels when defined" do
      allow(VoogFooter).to receive(:configuration).and_return(
        instance_double(VoogFooter::Configuration, enabled: true, site_url: "https://www.internet.ee")
      )
      allow(VoogFooter).to receive(:structure).and_return(
        "en" => {
          "columns" => [
            {
              "links" => [
                { "key" => "faq", "url" => "https://www.internet.ee/help-and-info/faq", "text" => "Voog FAQ label" }
              ],
              "social_links" => []
            }
          ]
        }
      )

      expect(helper.footer_link_label(:faq)).to eq("FAQ")
    end

    it "falls back to i18n when Voog fetching is disabled" do
      allow(VoogFooter).to receive(:configuration).and_return(
        instance_double(VoogFooter::Configuration, enabled: false, site_url: "https://www.internet.ee")
      )

      expect(helper.footer_link_label(:faq)).to eq("FAQ")
    end

    it "falls back to Voog link text when i18n label is missing" do
      allow(VoogFooter).to receive(:configuration).and_return(
        instance_double(VoogFooter::Configuration, enabled: true, site_url: "https://www.internet.ee")
      )
      allow(VoogFooter).to receive(:structure).and_return(
        "en" => {
          "columns" => [
            {
              "links" => [
                { "key" => "custom_voog_key", "url" => "https://www.internet.ee/custom", "text" => "From Voog" }
              ],
              "social_links" => []
            }
          ]
        }
      )

      expect(helper.footer_link_label(:custom_voog_key)).to eq("From Voog")
    end

    it "falls back to common.footer when Voog link text is blank" do
      allow(VoogFooter).to receive(:configuration).and_return(
        instance_double(VoogFooter::Configuration, enabled: true, site_url: "https://www.internet.ee")
      )
      allow(VoogFooter).to receive(:structure).and_return(
        "en" => {
          "columns" => [
            {
              "links" => [
                { "key" => "faq", "url" => "https://www.internet.ee/en/faq", "text" => "" }
              ],
              "social_links" => []
            }
          ]
        }
      )

      expect(helper.footer_link_label(:faq)).to eq("FAQ")
    end
  end

  describe "#footer_highlight_info" do
    it "sanitizes Voog info with br tags" do
      allow(VoogFooter).to receive(:configuration).and_return(
        instance_double(VoogFooter::Configuration, enabled: true, site_url: "https://www.internet.ee")
      )
      allow(VoogFooter).to receive(:structure).and_return(
        "en" => {
          "highlight" => { "info" => "Line one<br>Line two" },
          "columns" => []
        }
      )

      expect(helper.footer_highlight_info).to eq("Line one<br>Line two")
    end
  end
end
