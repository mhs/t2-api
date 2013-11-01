if !Rails.env.test?
  Paperclip::Attachment.default_options.merge!({
    storage: :s3,
    bucket: ENV['S3_BUCKET'],
    s3_credentials: {
      access_key_id: ENV['S3_ACCESS_KEY_ID'],
      secret_access_key: ENV['S3_SECRET_ACCESS_KEY']
    }
  })
end
