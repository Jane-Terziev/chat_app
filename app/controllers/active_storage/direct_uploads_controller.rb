# frozen_string_literal: true

# Creates a new blob on the server side in anticipation of a direct-to-service upload from the client side.
# When the client-side upload is completed, the signed_blob_id can be submitted as part of the form to reference
# the blob that was created up front.
class ActiveStorage::DirectUploadsController < ActiveStorage::BaseController
  before_action :authenticate_user!

  ALLOWED_FILE_TYPES = %w[image/jpeg image/png image/jpg application/pdf]

  def create
    unless ALLOWED_FILE_TYPES.include?(params[:blob][:content_type])
      render json: {
        error: "Unsupported File Type #{params[:blob][:content_type]} for file #{params[:blob][:filename]}"
      }, status: 422 and return
    end

    if params[:blob][:byte_size] > 2.megabytes
      render json: {
        error: "File #{params[:blob][:filename]} is too big."
      }, status: 422 and return
    end

    blob = ::ActiveStorageBlob.create_before_direct_upload!(
      **blob_args.merge(key: find_folder_path_from_referer, user_id: current_user.id)
    )

    render json: direct_upload_json(blob)
  end

  def destroy
    ::ActiveStorageBlob.where(user_id: current_user.id, filename: params[:file_names]).destroy_all
    head :ok
  end

  private

  def blob_args
    params.require(:blob).permit(:filename, :byte_size, :checksum, :content_type, metadata: {}).to_h.symbolize_keys
  end

  def direct_upload_json(blob)
    blob.as_json(root: false, methods: :signed_id).merge(direct_upload: {
      url: blob.service_url_for_direct_upload,
      headers: blob.service_headers_for_direct_upload
    })
  end

  def find_folder_path_from_referer
    path = request.referer.sub("#{request.origin}/", '')
    puts path
    if path == 'users'
      "#{path}/#{current_user.id}/profile_images/#{SecureRandom.base36(28)}"
    else
      "#{path}/#{current_user.id}/#{SecureRandom.base36(28)}"
    end
  end
end