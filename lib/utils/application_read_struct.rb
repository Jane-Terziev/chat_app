class ApplicationReadStruct < Dry::Struct
  transform_types {|type| type.optional }
end