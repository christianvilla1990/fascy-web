class SiteSetting < ApplicationRecord
  has_one_attached :logo
  has_one_attached :logo_mobile

  def self.current
    first_or_create!
  rescue ActiveRecord::RecordNotUnique
    first
  end
end
