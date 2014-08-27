class EmailProfileImage < ActiveRecord::Base
  mount_uploader :image, EmailProfileImageUploader

  def cache_image
    begin
      self.remote_image_url = self.url
      self.active = true
      save!
    rescue Cloudinary::CarrierWave::UploadError, RestClient::RequestTimeout => e
      # Probably an old/non-existent image
    end
  end
end
