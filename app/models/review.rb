class Review < ApplicationRecord
    mount_uploader :image, ImageUploader
    validates :title, presence: true
    belongs_to :user, optional: true
    has_many :reviewtags, dependent: :destroy
    has_many :reviewtag_hashtags, through: :reviewtags, source: :hashtag
    accepts_nested_attributes_for :reviewtags, allow_destroy: true
    has_many :favorites, dependent: :destroy
    has_many :favorite_users, through: :favorites, source: :user
    has_many :likes, dependent: :destroy
    has_many :like_users, through: :likes, source: :user
    has_many :comments, dependent: :destroy
    
    acts_as_taggable_on :labels # post.label_list が追加される
    acts_as_taggable            # acts_as_taggable_on :tags のエイリアス
    acts_as_ordered_taggable_on :skills, :interests

  # 与えられたユーザーがフォローしているユーザー達のマイクロポストを返す。
  def self.from_users_following_by(user)
    following_user_ids = "SELECT following_id FROM relationships
                         WHERE following_id = :user_id"
    where("user_id IN (#{following_user_ids}) OR user_id = :user_id",
          user_id: user.id)
  end

is_impressionable

end
