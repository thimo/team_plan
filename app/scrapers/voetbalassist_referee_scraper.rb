require "open-uri"
require "uri"

class VoetbalassistRefereeScraper
  delegate :host, to: :uri
  delegate :scheme, to: :uri

  def run
    return [] if url.blank?

    doc = Nokogiri::HTML(URI.open(url))
    programma_tabel_body = doc.at_css("#ProgrammaTabel tbody")
    programma_tabel_body.css("tr").map do |row|
      cells = row.css("td")
      referee = cells.slice(1).text

      [wedstrijdnummer(cells.last), referee.presence]
    end.compact
  end

  private

    def url
      @url ||= Tenant.setting("voetbalassist_referee_url")
    end

    def uri
      @uri ||= URI.parse(url)
    end

    def wedstrijdnummer(cell)
      doc = Nokogiri::XML(URI.open(match_url(cell)))
      Nokogiri::HTML(doc.root.text).css(".waarde").slice(2)&.text
    end

    def match_url(cell)
      "#{scheme}://#{host}#{cell.attr('data-url')}?objectid=#{cell.attr('data-objectid')}"
    end
end
