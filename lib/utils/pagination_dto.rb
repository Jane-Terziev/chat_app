require_relative 'application_read_struct'

class PaginationDto < ApplicationReadStruct
  attribute :pagination, Types::Any
  attribute :data, Types::Array
end
