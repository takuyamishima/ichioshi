class HomesController < ApplicationController
  def index
    @users = User.all
    @review = Review.all
    @user = current_user
    @tag =  ActsAsTaggableOn::Tag.all
    if user_signed_in?
    @feed_items = current_user.feed
    else
    end
  end
end
