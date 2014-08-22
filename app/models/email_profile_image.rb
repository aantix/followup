class EmailProfileImage < ActiveRecord::Base

  def self.download_images_for(email)
    result = PossibleEmail.find_profile(email)
    return unless result.respond_to? :data

    data = result.data
    if data.key?("contact") && data["contact"].key?("images")

      data["contact"]["images"].each do |image|
        EmailProfileImage.find_or_create_by(email: email, url: image["url"])
      end

    end
  end
end
