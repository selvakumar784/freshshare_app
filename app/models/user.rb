class User < ActiveRecord::Base
  attr_accessible :email, :name, :password, :password_confirmation
  attr_accessible :password_reset_token, :password_reset_sent_at
  has_secure_password

  has_many :offerrides, dependent: :destroy
  has_many :bookrides, dependent: :destroy
  before_save :downcase_fields
  before_save :create_remember_token

  validates :name, presence: true, length: { maximum:50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence:true, format: { with:VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  validates :password, presence: true, length: { minimum: 6}
  validates :password_confirmation, presence: true

  def downcase_fields
    self.email.downcase!
    self.name.downcase!
  end

  def send_password_reset(user)
    @cur_user = User.find_by_email(user.email)
    password_reset_token = SecureRandom.urlsafe_base64
    password_reset_sent_at = Time.zone.now
    @cur_user.update_attribute(:password_reset_token, password_reset_token)
    @cur_user.update_attribute(:password_reset_sent_at, password_reset_sent_at)
    @cur_user.save
    UserMailer.password_reset(@cur_user).deliver
  end

  private
    def create_remember_token
      self.remember_token = SecureRandom.urlsafe_base64
    end
end
