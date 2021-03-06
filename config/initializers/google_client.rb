Encoding.default_external="UTF-8"
Encoding.default_internal = Encoding.default_external

$google_api_client = Google::APIClient.new(
    application_name: 'Followup',
    application_version: '1.0.0'
    #force_encoding: true
)

auth = Signet::OAuth2::Client.new

auth.client_id = ENV.fetch('GOOGLE_APP_ID')
auth.client_secret = ENV.fetch('GOOGLE_SECRET_ID')
auth.authorization_uri = 'https://accounts.google.com/o/oauth2/auth'
auth.token_credential_uri = 'https://accounts.google.com/o/oauth2/token'
auth.scope = 'https://mail.google.com/'

$google_api_client.authorization = auth

json = Rails.root.join('config/gmail_api.json').read
$google_api_client.register_discovery_document 'gmail', 'v1', json

$gmail_api = $google_api_client.discovered_api 'gmail', 'v1'
