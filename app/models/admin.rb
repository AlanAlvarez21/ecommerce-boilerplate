class Admin < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  # Fix for Rails 8 and Devise compatibility
  def self.serialize_from_session(key, salt = nil)
    record = find_by(id: key)
    return record unless salt
    record if record && record.authenticatable_salt == salt
  end
end
