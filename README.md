Spicyham
========

A small web app to modify domains and zones on Gandi.

### Requirements

 * Ruby v2.0.0
 * Rails 4
 * Postgres 9.1
 * Gandi API Key
 * Google Auth Key

### Setup

 $ git clone git@github.com:ollej/spicyham.git
 $ cd spicyham
 $ bundle install
 $ export GOOGLE_CLIENT_ID='XXXXXX.apps.googleusercontent.com'
 $ export GOOGLE_CLIENT_SECRET='<secret>'
 $ export GANDI_API_KEY="<gandi api key>"
 $ export GANDI_HOST="rpc.gandi.net"
 $ export GANDI_MAIL_DOMAIN="example.com"
 $ export SECRET_TOKEN="<rails secret token>"
 $ rails s