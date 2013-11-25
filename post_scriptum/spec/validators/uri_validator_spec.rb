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
end
