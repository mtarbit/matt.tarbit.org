require 'digest/sha2'

class User < ActiveRecord::Base
  validates_presence_of :username
  validates_uniqueness_of :username

  def password
    @password
  end

  def password=(password)
    @password = password
    self.password_salt = User.generate_salt
    self.password_hash = User.encrypted_password(self.password, self.password_salt)
  end
  
  def self.authenticate(username, password)
    user = self.find_by_username(username)
    if user
      expected_password = encrypted_password(password, user.password_salt)
      if user.password_hash != expected_password
        user = nil
      end
    end
    user
  end

private

  def self.encrypted_password(password, salt)
    Digest::SHA256.hexdigest(password + salt)
  end

  def self.generate_salt
    [Array.new(6){rand(256).chr}.join].pack('m').chomp
  end

end
