# frozen_string_literal: true

require "open-uri"
require "uri"

class RefereeImportJob < ApplicationJob
  queue_as :default

  delegate :host, to: :uri
  delegate :scheme, to: :uri

  def perform(tenant_id:)
    ActsAsTenant.current_tenant = Tenant.find(tenant_id)
    return if url.blank?

    # Fetch url and parse with Nokogiri
    doc = Nokogiri::HTML(open(url))
    programma_tabel_body = doc.at_css("#ProgrammaTabel tbody")
    programma_tabel_body.css("tr").each do |row|
      cells = row.css("td")
      next if (referee = cells.slice(1).text).blank?

      match = Match.find_by(wedstrijdnummer: wedstrijdnummer(cells.last))
      # debugger
      match.update(website_referee: referee) if match.present?
    end

    # Find HTML table to parse
    # Schedule matches
    true
  end

  def url
    @url ||= Tenant.setting("voetbalassist_referee_url")
  end

  def uri
    @uri ||= URI.parse(url)
  end

  def wedstrijdnummer(cell)
    doc = Nokogiri::XML(open(match_url(cell)))
    Nokogiri::HTML(doc.root.text).css(".waarde").last.text
  end

  def match_url(cell)
    "#{scheme}://#{host}#{cell.attr('data-url')}?objectid=#{cell.attr('data-objectid')}"
  end
end
