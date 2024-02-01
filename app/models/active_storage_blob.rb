class ActiveStorageBlob < ActiveStorage::Blob
  def self.create_before_direct_upload!(key: nil, filename:, byte_size:, checksum:, content_type: nil, metadata: nil, service_name: nil, user_id: nil)
    create!(
      key: key,
      filename: filename,
      byte_size: byte_size,
      checksum: checksum,
      content_type: content_type,
      metadata: metadata,
      service_name: service_name,
      user_id: user_id
    )
  end
end
