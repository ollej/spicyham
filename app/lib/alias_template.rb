class AliasTemplate
  RANDOM_CHARS = '0123456789'
  LENGTH = 8

  def initialize(url, template)
    @url = url
    @template = template
  end

  def generate
    @template
      .gsub(/{DOMAIN}/, parse_email_domain(@url))
      .gsub(/{RANDOM}/, generate_random_string(LENGTH))
      .gsub(/{UUID}/, SecureRandom.uuid)
      .gsub(/{ALPHA}/, SecureRandom.alphanumeric(LENGTH))
      .gsub(/{HEX}/, SecureRandom.hex(LENGTH/2))
  end

  private
  def generate_random_string(length = 8)
    length.times.map{SecureRandom.rand(10)}.join
  end

  def parse_email_domain(url)
    return "" unless url.present?
    url.gsub(/^https?:\/\//, "") # Strip protocol
      .gsub(/#.*$/, "") # Strip all after anchor
      .gsub(/\?.*$/, "") # Strip argument list
      .gsub(/\/.*/, "") # Strip from first slash
      .gsub(/:\d+$/, "") # Strip port
      .gsub(/@/, "") # Strip @
      .gsub(/www\./, "") # Strip sub-domain
      .gsub(/.(?:co|org|ltd|gov|net|me|mil|ac|mod|nhs|nic|plc|sch)(.uk)$/, '\1') # Strip second level TLD in UK
      .gsub(/.(?:com|net|org|edu|gov|asn|id|csiro)(.au)$/, '\1') # Strip second level TLD in AU
      .gsub(/.(?:co|or|priv|ac|gv)(.at)$/, '\1') # Strip second level TLD in AT
      .gsub(/.(ac|co|geek|gen|kiwi|maori|net|org|school|cri|govt|health|iwi|mil|parliament)(.nz)$/, '\1') # Strip second level TLD in NZ
      .gsub(/\.[^.]*$/, "") # Strip TLD
      .gsub(/^.*\./, "") # Leave last sub-domain
  end
end
