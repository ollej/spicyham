Spicyham
========

A small web app to modify domains and zones on Gandi.

### Requirements

 * Ruby v3.4.1
 * Rails 7.1
 * Postgres 12
 * Gandi API Key
 * Google Auth Key

### Setup

```bash
 $ git clone git@github.com:ollej/spicyham.git
 $ cd spicyham
 $ bundle install
 $ export GOOGLE_CLIENT_ID='XXXXXX.apps.googleusercontent.com'
 $ export GOOGLE_CLIENT_SECRET='<secret>'
 $ export GANDI_API_KEY="<gandi api key>"
 $ export GANDI_HOST="rpc.gandi.net"
 $ export GANDI_MAIL_DOMAIN="example.com"
 $ export GANDI_NAMESERVERS="a.dns.gandi.net b.dns.gandi.net c.dns.gandi.net"
 $ export GANDI_DOMAIN_API_KEY="<gandi api key>"
 $ export GANDI_DOMAIN_HOST="rpc.gandi.net"
 $ export GANDI_CONTACT="XXNNN-GANDI"
 $ export GANDI_CONTACT_OWNER="XXNNN-GANDI"
 $ export SECRET_TOKEN="`rails secret`"
 $ rails s
```
