class FollowupProfileInfoJob < ActiveJob::Base
  def perform(email)
    result = PossibleEmail.find_profile(email)
    return unless result.respond_to? :data

    data = result.data
    if data.key?("contact") && data["contact"].key?("images")

      data["contact"]["images"].each do |nimage|
        EmailProfileImageJob.perform_later(email, nimage["url"])
      end
    end
  end
end
