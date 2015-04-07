class User
  include Mongoid::Document
  field :provider, type: String
  field :uid, type: String
  field :name, type: String
  field :email, type: String
  field :oauth_token, type: String
  field :oauth_expires_at, type: DateTime
  
  before_validation :whitelisted
  
  AUTHORIZED_USERS = %w{alagiboy@gmail.com serignjobe@gmail.com oumiejawo@gmail.com}
  
  def self.from_omniauth(auth)
    where(auth.slice(:provider, :uid)).first_or_initialize.tap do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.name = auth.info.name
      user.email = auth.info.email 
      user.oauth_token = auth.credentials.token
      user.oauth_expires_at = Time.at(auth.credentials.expires_at)
      user.save!
    end
  end
  
  def whitelisted
    unless AUTHORIZED_USERS.include?(self.email) 
      errors.add :email, "This email does not have the correct authorizations to access this site." 
    end
  end

end
