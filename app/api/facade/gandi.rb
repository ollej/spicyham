class Facade::Gandi
  def initialize(key:, domain:, user: nil)
    @gandi = Gandi::API.new(ENV['GANDI_HOST'], key)
    @email_server = Gandi::Email.new(@gandi, domain)
  end

  def emails(all: false)
    begin
      return @email_server.list({
        items_per_page: all ? 500 : 20,
        sort_by: 'source'
      })
    rescue XMLRPC::FaultException => e
      Rails.logger.error { "Gandi::API error domain.email.list: #{e.message}" }
      error = Gandi::parse_error(e.message)
      raise Facade::Error.new(error)
    end
  end

  def delete(email:)
    begin
      @email_server.delete(email)
    rescue XMLRPC::FaultException => e
      Rails.logger.error { "Gandi::API error domain.email.delete: #{e.message}" }
      error = Gandi::parse_error(e.message)
      raise Facade::Error.new(error)
    end
  end

  def create(email:, destinations:)
    begin
      @email_server.create(email, { 'destinations' => destinations })
    rescue XMLRPC::FaultException => e
      Rails.logger.error { "Gandi::API error domain.email.create: #{e.message}" }
      error = Gandi::parse_error(e.message)
      raise Facade::Error.new(error)
    end
  end
end
