class EmailProfileImageWorker
  include Sidekiq::Worker

  EMAIL_LOOKUP = 'email'
  IMAGE_LOOKUP = 'image'

  def perform(email, image_url = nil, perform_type = EMAIL_LOOKUP)
    if perform_type == EMAIL_LOOKUP
      result = PossibleEmail.find_profile(email)
      return unless result.respond_to? :data

      data = result.data
      if data.key?("contact") && data["contact"].key?("images")

        data["contact"]["images"].each do |nimage|
          EmailProfileImageWorker.perform_async(email, nimage["url"], IMAGE_LOOKUP)
        end
      end
    elsif perform_type == IMAGE_LOOKUP
      profile_image = EmailProfileImage.find_or_create_by(email: email, url: image_url)
      profile_image.cache_image
    end
  end
end