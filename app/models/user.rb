class User < ApplicationRecord
  mount_uploader :avator, IconUploader
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  has_many :reviews
  has_many :favorites, dependent: :destroy
  has_many :favorite_reviews, through: :favorites, source: :review
  
  has_many :following_relationships, foreign_key: "follower_id", class_name: "Relationship", dependent: :destroy
  has_many :followings, through: :following_relationships
  has_many :follower_relationships, foreign_key: "following_id", class_name: "Relationship", dependent: :destroy
  has_many :followers, through: :follower_relationships
  
  has_many :reviews, dependent: :destroy
  has_many :comments, dependent: :destroy
  
  validates :name, presence: true, length: { maximum: 50 }
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  def following?(other_user)
    following_relationships.find_by(following_id: other_user.id)
  end

  def follow!(other_user)
    following_relationships.create!(following_id: other_user.id)
  end

  def unfollow!(other_user)
    following_relationships.find_by(following_id: other_user.id).destroy
  end

  def feed
    following_ids = "SELECT following_id FROM relationships
                     WHERE follower_id = :user_id"
    Review.where("user_id IN (#{following_ids})
                     ", user_id: id)
  end

         def self.find_for_facebook_oauth(auth)
          user = User.where(uid: auth.uid, provider: auth.provider).first

          unless user
            user = User.create(
              uid:      auth.uid,
              provider: auth.provider,
              email:    auth.info.email,
              name:     auth.info.name,
              icon:     auth.info.image,
              password: Devise.friendly_token[0, 20]
            )
          end

          return user
        end
end
