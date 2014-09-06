class EmailProfileImageWorker
  include Sidekiq::Worker

  def perform(email, image_url)
    profile_image = EmailProfileImage.find_or_create_by(email: email, url: image_url)
    profile_image.cache_image
  end
end