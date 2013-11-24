require 'rest-client'

class UriValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    resp = valid_uri? value

    if resp == false
      record.errors[attribute] << 'is not an uri'
    else
      record.errors[attribute] << 'is not available' unless available? value
    end
  end

  def valid_uri?(url)
    uri = URI.parse(url)  # throws InvalidURIError
    uri.kind_of?(URI::HTTP)
  rescue URI::InvalidURIError
    false
  end

  def available?(url)
    response_code = send_head_request(url)
    response_code == 200
  rescue # RestClient::RequestTimeout or others
    false
  end

  def send_head_request(url)
    RestClient::Request.execute(
      method:       :head,
      url:          url,
      timeout:      1,
      open_timeout: 1
    ).code
  end
end
