class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :courses

  def username
    if email.present?
      self.email.split(/@/).first
    end
  end
  
  def to_s
    username
  end
end