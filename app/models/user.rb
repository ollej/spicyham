class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :omniauthable,
         :rememberable, :trackable, :validatable,
         :omniauth_providers => [:google_oauth2]

  #attr_accessible :email, :password, :password_confirmation, :remember_me, :provider, :uid

  def self.from_omniauth(auth)
    if user = User.find_by_email(auth.info.email)
      user.provider = auth.provider
      user.uid = auth.uid
      user.save!
      logger.debug { "logged in user: #{user.inspect}" }
      user
    else
      #where(auth.slice(:provider, :uid)).first_or_create do |u|
      #  u.provider = auth.provider
      #  u.uid = auth.uid
      #  u.email = auth.info.email
      #end
      logger.error { "--------------> User not found." }
      return nil
    end
  end
end
