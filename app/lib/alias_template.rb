class AliasTemplate
  RANDOM_CHARS = '0123456789'
  LENGTH = 8

  def initialize(url, template)
    @url = url
    @template = template.presence || "{DOMAIN}"
  end

  def generate
    @template
      .gsub(/{DOMAIN}/, parse_email_domain(@url))
      .gsub(/{RANDOM}/, generate_random_numbers(LENGTH))
      .gsub(/{UUID}/, SecureRandom.uuid)
      .gsub(/{ALPHA}/, SecureRandom.alphanumeric(LENGTH))
      .gsub(/{HEX}/, SecureRandom.hex(LENGTH/2))
  end

  private
  def generate_random_numbers(length = 8)
    length.times.map{SecureRandom.rand(10)}.join
  end

  def parse_email_domain(url)
    return "" unless url.present?
    host = url.gsub(/^https?:\/\//, "") # Strip protocol
      .gsub(/#.*$/, "")   # Strip fragment
      .gsub(/\?.*$/, "")  # Strip query
      .gsub(/\/.*/, "")   # Strip path
      .gsub(/:\d+$/, "")  # Strip port
      .gsub(/.*@/, "")    # Strip email prefix
      .gsub(/^www\./, "") # Strip www

    PublicSuffix.parse(host).sld.to_s
  rescue PublicSuffix::Error
    host.gsub(/\.[^.]*$/, "").gsub(/^.*\./, "")
  end
end
