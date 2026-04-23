Spicyham
========

A small web app to modify email aliases, domains, zones and web redirects on Gandi.

It also supports editing email aliases on Migadu and Glesys.

### Requirements

 * Ruby v4.0.3
 * Rails 8.1
 * Postgres 12
 * API Key for Migadu, Glesys or Gandi
 * Google Auth Key

### Setup

Clone code repository, run bundle install and create database.

```sh
git clone git@github.com:ollej/spicyham.git
cd spicyham
bundle install
bin/rails db:setup
```

Copy `.env.sample` to `.env` and update the variables.

Google OAuth2 credentials are needed for authentication.

```
GOOGLE_CLIENT_ID='XXXXXX.apps.googleusercontent.com'
GOOGLE_CLIENT_SECRET='<secret>'
```

Gandi XMLRPC API is needed to use the admin pages for editing Zones, Domains and Web Redirects.

```
GANDI_API_KEY="<gandi api key>"
GANDI_HOST="rpc.gandi.net"
GANDI_MAIL_DOMAIN="example.com"
GANDI_NAMESERVERS="a.dns.gandi.net b.dns.gandi.net c.dns.gandi.net"
GANDI_DOMAIN_API_KEY="<gandi api key>"
GANDI_DOMAIN_HOST="rpc.gandi.net"
GANDI_CONTACT="XXNNN-GANDI"
GANDI_CONTACT_OWNER="XXNNN-GANDI"
```

Generate a secret token for Rails using `bin/rails secret`.

```
SECRET_TOKEN="secret token"
```

Run development server:

```sh
bin/dev
```
