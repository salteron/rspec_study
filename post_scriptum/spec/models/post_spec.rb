require 'spec_helper'

describe Post do
  before { @post = Post.new() }

  subject { @post }

  it { should respond_to(:title) }
  it { should respond_to(:content) }
  it { should respond_to(:user_id) }
  it { should respond_to(:image_url) }
end
