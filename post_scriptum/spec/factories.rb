FactoryGirl.define do
  factory :user do
    email 'a@b.com'
    name  'bob'
  end

  factory :post do
    title     'title'
    content   'content'
    user
    image_url 'http://rubyonrails.org/images/rails.png'
    slug      '1-title'

    factory :post_with_invalid_title do
      title  nil
    end
  end
end
