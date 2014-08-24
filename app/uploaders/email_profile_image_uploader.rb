# encoding: utf-8

class EmailProfileImageUploader < CarrierWave::Uploader::Base
  include Cloudinary::CarrierWave
  process :convert => 'jpg'

  version :small do
    process :resize_to_fill => [50, 50, :fill]
    cloudinary_transformation :quality => 80
  end

  version :bright_face_small do
    cloudinary_transformation :effect => "brightness:20", :radius => 20,
                              :width => 50, :height => 50, :crop => :thumb, :gravity => :face
  end


  version :medium do
    process :resize_to_fill => [100, 100, :fill]
    cloudinary_transformation :quality => 80
  end

  version :bright_face_medium do
    cloudinary_transformation :effect => "brightness:20", :radius => 20,
                              :width => 100, :height => 100, :crop => :thumb, :gravity => :face
  end

  version :large do
    process :resize_to_fill => [150, 150, :fill]
    cloudinary_transformation :quality => 80
  end

  version :large do
    cloudinary_transformation :effect => "brightness:20",
                              :radius => 20,
                              :width => 150, :height => 150,
                              :crop => :thumb,
                              :gravity => :face
  end

end
