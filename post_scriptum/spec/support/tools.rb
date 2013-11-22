def sign_in user
  request.cookies['user_id'] = user.id
end

def mock_twitter
  fake_twitter = double('FakeTwitter')

  fake_twitter.stub(:update).
    with(an_instance_of(String), an_instance_of(String))

  stub_const('Twitter', fake_twitter)

  fake_twitter
end

def mock_uri_validator
  fake_uri_validator = double('FakeUriValidator')

  fake_uri_validator.stub(:validate_each).
    with(an_instance_of(Post), an_instance_of(Symbol), an_instance_of(String))

  stub_conts('UriValidator', fake_uri_validator)

  fake_uri_validator
end