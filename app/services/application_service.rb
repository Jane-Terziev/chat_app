class ApplicationService
  include Import[event_publisher: 'events.publisher']
  include Pagy::Backend

  def paginate_collection(collection:, mapper:, page:, page_size:, filter:, size: 5)
    result = pagy(collection.ransack(filter).result, items: page_size, page: page, size: size)

    pagy_metadata = result[0]
    paginated_data = result[1]

    PaginationDto.new(
      data: map_into(paginated_data, mapper),
      pagination: pagy_metadata
    )
  end

  def map_into(data, mapper, options = {})
    DryObjectMapper::Mapper.call(data, mapper, options)
  end

  def publish_all(aggregate_root)
    event_publisher.publish_all(aggregate_root.domain_events)
  end
end