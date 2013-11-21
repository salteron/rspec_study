class PostsController < ApplicationController
  respond_to :html

  def new
    @post = current_user.posts.build
  end

  def update
    @post = current_user.posts.find(params[:id])

    if @post.update_attributes(params[:post])
      redirect_to user_post_path(current_user, @post), 
        :notice => "Post saved successfully"
    else
      render :new
    end
  end

  private
  def current_user
    # Для простоты
    @user ||= User.find_by_id cookies[:user_id]
  end
end
