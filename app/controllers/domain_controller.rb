class DomainController < ApplicationController
  def list
    @domains = @gandi.call("domain.list", { 'sort_by' => 'fqdn' })
  end

  def info
    @domain = @gandi.call("domain.info", params[:domain])
  end

  def webredir
    @webredirs = @gandi.call_domain("webredir.list")
  end
end
