class FakeModel
  include ActiveModel::Validations

  attr_accessor :url

  validates :url, :uri => true
end
