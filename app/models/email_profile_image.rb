class EmailProfileImage < ActiveRecord::Base
  mount_uploader :image, EmailProfileImageUploader

  def self.download_images_for(email)
    result = PossibleEmail.find_profile(email)
    return unless result.respond_to? :data

    data = result.data
    if data.key?("contact") && data["contact"].key?("images")

      data["contact"]["images"].each do |nimage|
        profile_image = EmailProfileImage.find_or_create_by(email: email, url: nimage["url"])
        profile_image.cache_image
      end

    end
  end

  def cache_image
    begin
      self.remote_image_url = self.url
      self.active = true
      save!
    rescue Cloudinary::CarrierWave::UploadError => e
      # Probably an old/non-existent image
    end
  end
end
