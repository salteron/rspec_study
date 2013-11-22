require 'rest-client'

class UriValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    begin
      uri = URI.parse(value)
      resp = uri.kind_of?(URI::HTTP)
    rescue URI::InvalidURIError
      resp = false
    end

    if resp == false
      record.errors[attribute] << (options[:message] || "is not an uri")
    else
      available = true

      begin
        available = RestClient::Request.execute(
          :method => :head, :url => value, :timeout => 1, :open_timeout => 1
        ) == 200
      rescue
        available = false
      end

      record.errors[attribute] << "is not available" if !available
    end

    # plus mock RestClient.head
  end
end
