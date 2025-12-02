class User < ApplicationRecord
  # Associations
  has_many :orders, dependent: :nullify
  belongs_to :province, optional: true

  # Devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Validations
  validates :first_name, :last_name, :address, :city, :postal, presence: true
  validates :postal,
            format: {
              with: /\A[ABCEGHJKLMNPRSTVXY]\d[ABCEGHJKLMNPRSTVWXYZ] ?\d[ABCEGHJKLMNPRSTVWXYZ]\d\z/i,
              message: "must be a valid Canadian postal code"
            }

  # Callbacks
  before_validation :normalize_postal_code

  # Helper methods
  def full_name
    "#{first_name} #{last_name}"
  end

  def full_address
    "#{address}, #{city}, #{province&.name}, #{postal}"
  end

  # Commented out to prevent error
  # def admin?
  #   role_admin?
  # end

  private

  def normalize_postal_code
    self.postal = postal&.upcase&.strip
  end

  # -------------------------
  # Ransack configuration
  # -------------------------
  # Allowlisted attributes for Ransack searches in ActiveAdmin
  def self.ransackable_attributes(auth_object = nil)
    %w[id first_name last_name email province_id created_at updated_at]
  end

  # Allowlisted associations for Ransack
  def self.ransackable_associations(auth_object = nil)
    %w[province]
  end
end
