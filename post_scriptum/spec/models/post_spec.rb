require 'spec_helper'

describe Post do
  let(:user) { FactoryGirl.create(:user) }
  let(:post) { FactoryGirl.build(:post, user: user) }

  subject { post }

  it { should respond_to(:title) }
  it { should respond_to(:content) }
  it { should respond_to(:user_id) }
  it { should respond_to(:image_url) }
  it { should respond_to(:slug) }
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
end
