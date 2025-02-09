class User < ApplicationRecord
  enum :api, { 'Gandi XML/RPC' => 'gandixmlrpc', 'Gandi v5' => 'gandiv5', 'Glesys' => 'glesys' }
  validates :api, inclusion: { in: apis.keys }, allow_nil: true

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :omniauthable,
         :rememberable, :trackable, :validatable,
         :omniauth_providers => [:google_oauth2]

  #attr_accessible :email, :password, :password_confirmation, :remember_me, :provider, :uid

  def api_name
    User.apis[api]
  end

  def self.from_omniauth(auth)
    if user = User.find_by_uid(auth.uid)
      logger.debug { "logged in user: #{user.inspect}" }
      user
    else
      logger.debug { "User not registered: #{auth.uid} / #{auth.info.email}" }
      User.new(
        provider: auth.provider,
        uid: auth.uid,
        email: auth.info.email,
        password: SecureRandom.hex
      )
    end
  end
end
