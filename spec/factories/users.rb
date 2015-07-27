# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    email "jim.jones1@gmail.com"
    encrypted_password "$2a$10$Wv3HKyxdHE6uNPLd0H8iWuS0dE9HNERONYq4zDs7p8OaY1YZ/W6Q2"
    image_url "https://lh3.googleusercontent.com/-R8yRgIkblF4/AAAAAAAAAAI/AAAAAAAAAbA/FXNq28uQMjo/photo.jpg?sz=50"
    reset_password_token nil
    reset_password_sent_at nil
    remember_created_at nil
    sign_in_count 4
    current_sign_in_at Time.now
    last_sign_in_at Time.now
    current_sign_in_ip "::1"
    last_sign_in_ip "::1"
    created_at Time.now
    updated_at Time.now
    provider "google_oauth2"
    uid "103844314870547781517"
    name "Jim Jones"
    omniauth_token "ya29.lAGG2pIAMSFZpQmGKm4jv4U2xm2dXxbJg4Q3JsbrUtaDb1trEstnFwbc5VCoeuY4OvzCSqTHYn6kxA"
    omniauth_refresh_token "1/Lof0l62xOTerct-K8Z6jWxPE9PEJ96Q3S2wSMOCdCktIgOrJDtdun6zK6XiATCKT"
    omniauth_expires_at Time.now() + 2.days
    omniauth_expires true
    time_zone "Pacific Time (US & Canada)"
    email_send Time.now
    admin false
    first_name "Jones"
    last_name "Jim"
  end
end
