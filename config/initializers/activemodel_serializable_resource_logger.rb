module ActiveModel
  class SerializableResource
    alias :orig_as_json :as_json
    def as_json(*args)
      p self
      orig_as_json(*args)
    end
  end
end
