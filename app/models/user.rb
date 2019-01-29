class User < ApplicationRecord
  mount_uploader :avator, IconUploader
  mount_uploader :coverimg, CoverimgUploader
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  has_many :reviews, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :favorite_reviews, through: :favorites, source: :review

  has_many :likes, dependent: :destroy
  has_many :like_reviews, through: :likes, source: :review

  has_many :following_relationships, foreign_key: "follower_id", class_name: "Relationship", dependent: :destroy
  has_many :followings, through: :following_relationships
  has_many :follower_relationships, foreign_key: "following_id", class_name: "Relationship", dependent: :destroy
  has_many :followers, through: :follower_relationships

  has_many :comments, dependent: :destroy

  has_many :notifications, dependent: :destroy
  has_many :notifications_ids, dependent: :destroy, class_name: 'Notification', foreign_key: "notified_by_id"

  validates :name, presence: true, length: { maximum: 50 }
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable
  
  is_impressionable

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
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
      if data = session["devise.facebook_data"]
        user.provider = data["provider"] if user.provider.blank?
        user.uid = data["uid"] if user.uid.blank?
        user.name = data["info"]["name"] if user.name.blank?
        user.icon = data["info"]["image"].insert(4,"s") if user.icon.blank?
        user.coverimg = data["info"]["coverimg"] if user.coverimg.blank?
        user.password = Devise.friendly_token[0,20] if user.password.blank?
      end
    end
  end

  # 今のパスワードを入力しなくてもユーザー情報を変更できるようにするメソッド
  def update_without_current_password(params, *options)
    params.delete(:current_password)

    if params[:password].blank? && params[:password_confirmation].blank?
      params.delete(:password)
      params.delete(:password_confirmation)
    end

    result = update_attributes(params, *options)
    clean_up_passwords
    result
  end
end
