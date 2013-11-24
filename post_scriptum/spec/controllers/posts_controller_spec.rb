require 'spec_helper'

describe PostsController do
  let(:user) { FactoryGirl.create(:user) }

  before do
    sign_in user
    mock_twitter
    mock_uri_validator
  end

  describe 'current_user' do
    it 'assigns correct user' do
      get :new

      expect(assigns(:user)).to eq user
    end
  end

  describe 'GET #new' do
    it 'builds new post' do
      post = user.posts.new
      get :new

      expect(assigns(:post).attributes).to eq post.attributes
    end
  end

  describe 'PUT #update' do
    before { @post = FactoryGirl.create(:post, user: user) }

    context 'with valid attributes' do
      it 'should locate the requested post' do
        put :update, id: @post, post: FactoryGirl.attributes_for(:post,
                                                                 user: user)
        expect(assigns(:post)).to eq @post
      end

      it 'should change @post attribute' do
        expect do
          put :update, id: @post, post: FactoryGirl.attributes_for(
            :post,
            user: user,
            title: 'new_title'
          )

          @post.reload
        end.to change(@post, :title).from('title').to('new_title')
      end

      it 'should redirect to @post' do
        put :update, id: @post, post: FactoryGirl.attributes_for(:post,
                                                                 user: user)

        response.should redirect_to user_post_path(user, @post)
        flash[:notice].should eq 'Post saved successfully'
      end
    end

    context 'with invalid attributes' do
      it 'should locate the requested post' do
        put :update, id: @post, post: FactoryGirl.attributes_for(
          :post_with_invalid_title,
          user: user
        )

        expect(assigns(:post)).to eq @post
      end

      it 'should not change @post attributes' do
        expect do
          put :update, id: @post, post: FactoryGirl.attributes_for(
            :post_with_invalid_title,
            user: user,
            content: 'new_content'
          )

          @post.reload
        end.not_to change(@post, :content)
      end

      it 'should render #new' do
        put :update, id: @post, post: FactoryGirl.attributes_for(
          :post_with_invalid_title,
          user: user
        )

        response.should render_template :new
      end
    end

    context 'with fake id' do
      it 'should raise RecordNotFound error' do
        lambda do
          put :update, id: 0, post: FactoryGirl.attributes_for(
            :post_with_invalid_title,
            user: user
          )
        end.should raise_error(ActiveRecord::RecordNotFound)

        # response.should render_template :new
      end
    end

    context "updating another user's post" do
      before do
        @another_user      = FactoryGirl.create(:user)
        @another_user_post = FactoryGirl.create(:post, user: @another_user)
      end

      it 'should raise RecordNotFound error' do
        lambda do
          put :update,
              id:   @another_user_post,
              post: @another_user_post.attributes
        end.should raise_error(ActiveRecord::RecordNotFound)
      end

      it 'should not change post' do
        expect do
          begin
            put :update,
                id:   @another_user_post,
                post: { title: 'new_title' }
          rescue ActiveRecord::RecordNotFound
          end
        end.not_to change(@another_user_post, :title)
      end
    end
  end
end
