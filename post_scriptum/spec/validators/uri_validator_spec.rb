require 'spec_helper'

describe UriValidator do
  let(:fake_model) { FakeModel.new }

  subject { fake_model }

  describe 'when url is invalid' do
    before { UriValidator.any_instance.stub(:valid_uri?).and_return(false) }

    it { should_not be_valid }
    it { should have(1).errors_on(:url) }

    it { expect(fake_model.errors_on(:url)).to include('is not an uri') }
  end

  describe 'when url is not available' do
    before { UriValidator.any_instance.stub(:valid_uri?).and_return(true) }

    context 'server responds with non-200 code' do
      before do
        UriValidator.any_instance.stub(:send_head_request).and_return(404)
      end

      it 'should send head request exactly once' do
        expect_any_instance_of(UriValidator).to receive(:send_head_request).
          exactly(1).times.with(fake_model.url)

         fake_model.valid?
      end

      it { should_not be_valid }

      it { should have(1).errors_on(:url) }


      specify { fake_model.errors_on(:url).should include('is not available') }
    end

    context 'connection timeout' do
      before do
        UriValidator.any_instance.stub(:send_head_request).and_raise(
          RestClient::RequestTimeout)
      end

      it { should_not be_valid }
      it { should have(1).errors_on(:url) }

      specify { fake_model.errors_on(:url).should include('is not available') }
    end
  end

  describe 'valid_uri?' do
    let(:uri_validator) { UriValidator.new(attributes: [:url]) }

    it 'should be valid' do
      uri = 'http://rubyonrails.org/images/rails.png'

      expect(uri_validator.valid_uri?(uri)).to eq true
    end

    it 'should not be valid' do
      uris = %w[a/b/c htt:/invalid.jpg http://www.ya.r#u#]

      uris.each do |uri|
         expect(uri_validator.valid_uri?(uri)).to eq false
      end
    end
  end
end
