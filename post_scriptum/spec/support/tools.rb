def sign_in(user)
  request.cookies['user_id'] = user.id
end

def mock_twitter
  fake_twitter = double('FakeTwitter')

  fake_twitter.stub(:update)
    .with(an_instance_of(String), an_instance_of(String))

  stub_const('Twitter', fake_twitter)

  fake_twitter
end

def mock_uri_validator
  UriValidator.any_instance.stub(:send_head_request).and_return(200)
  UriValidator.any_instance.stub(:valid_uri?).and_return(true)
end
