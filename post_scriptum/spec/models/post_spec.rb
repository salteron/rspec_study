require 'spec_helper'

describe Post do
  let(:user) { FactoryGirl.create(:user) }
  let(:post) { FactoryGirl.build(:post, user: user) }
  let(:fake_twitter) { double('FakeTwitter') }

  before do
    fake_twitter.stub(:update).
      with(an_instance_of(String), an_instance_of(String))

    stub_const('Twitter', fake_twitter)
  end

  subject { post }

  it { should respond_to(:title) }
  it { should respond_to(:content) }
  it { should respond_to(:user_id) }
  it { should respond_to(:image_url) }
  it { should respond_to(:slug) }
  it { should respond_to(:status_id) }
  its(:user) { should eq user }

  it { should be_valid }

  describe 'when title is not present' do
    before { post.title = nil }
    it { should_not be_valid }
  end

  describe 'when title is blank' do
    before { post.title = '  ' }
    it { should_not be_valid }
  end

  describe 'when title is too long' do
    before { post.title = 'a' * 51 }
    it { should_not be_valid }
  end

  describe 'when content is not present' do
    before { post.content = nil }
    it { should_not be_valid }
  end

  describe 'when content is blank' do
    before { post.content = '  ' }
    it { should_not be_valid }
  end

  describe 'when user is not present' do
    before { post.user = nil }
    it { should_not be_valid }
  end

  describe 'when image_url is invalid' do
    it 'should not be valid' do
      invalid_urls = %w[not_url ..bad_one /a/b/c
                        http://www.example.com/image.jp#g#]

      invalid_urls.each do |invalid_url|
        post.image_url = invalid_url

        expect(post).not_to be_valid
        expect(post.errors[:image_url]).not_to be_empty
      end
    end
  end

  describe 'after validation with blank slug' do
    before do
      post.slug = nil
      post.valid?
    end

    its(:slug) { should_not be_nil }
  end

  describe 're-validation with changed title' do
    it 'should not change slug' do
      expect do
        post.title = 'new_title'
        post.valid?
      end.not_to change(post, :slug)
    end
  end

  describe 'when user has a post with the same slug' do
    let(:another_post) { post.dup }

    before do
      post.save
      another_post.valid?
    end

    subject { another_post }

    it { should_not be_valid }
    specify { another_post.errors[:slug].should_not be_empty }
  end

  describe 'after creating' do
    it 'should notify twitter' do
      post.should_receive(:notify_twitter)
      post.save
    end

    it 'twitter should receive #update' do
      expect(fake_twitter).to receive(:update).with(post.title, post.content)
      post.save
    end
  end

  describe "when (re-)assigning attributes' values" do
    context 'via mass-assigning' do
      it 'should not change image_url' do
        new_image_url = 'www.example.com/new_url'

        expect do
          post.attributes = { title: 'new_title',
                              image_url: new_image_url }
        end.not_to change(post, :image_url)
      end

      it 'should not change user_id' do
        new_user_id = post.user_id + 1

        expect do
          post.attributes = { title: 'new_title', user_id: new_user_id }
        end.not_to change(post, :user_id)
      end

      it 'should not change slug' do
        new_slug = post.slug + 'postfix'

        expect do
          post.attributes = { title: 'new_title', slug: new_slug }
        end.not_to change(post, :slug)
      end
    end

    context 'via single assigning' do
      it 'should change image_url' do
        new_image_url = 'www.example.com/new_url'

        expect do
          post.image_url = new_image_url
        end.to change(post, :image_url).to(new_image_url)
      end

      it 'should change slug' do
        new_slug = post.slug + 'postfix'
        expect do
          post.slug = new_slug
        end.to change(post, :slug).to(new_slug)
      end

      it 'should change user_id' do
        expect do
          post.user_id += 1
        end.to change(post, :user_id).by(1)
      end
    end
  end

  describe 'posted_to_twitter?' do
    before do
      post.stub(:status_id) { 42 }
      fake_twitter.stub(:status).with(instance_of(Fixnum)).and_return(false)
    end

    it 'Twitter.status should receive status_id' do
      expect(fake_twitter).to receive(:status).with(post.status_id)
      post.posted_to_twitter?
    end

    it 'should return false if twitter status is false' do
      expect(post.posted_to_twitter?).to be_false
    end

  end
end
