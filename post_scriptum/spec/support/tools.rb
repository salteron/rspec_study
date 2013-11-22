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