class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :portfolios, foreign_key: 'user_id', class_name: 'Portfolio'
  has_many :transactions, through: :portfolios
  has_many :holdings, through: :portfolios

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true

  before_save :normalise_attributes

  def to_s
    "
    User ID: #{id},
    First Name: #{first_name},
    Last Name: #{last_name},
    Username: #{username}
    Email: #{email},
    ".squish
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  private

  def normalise_attributes
    self.email = email.downcase.strip if email.present?
    self.username = username.downcase.strip if username.present?
  end
end
