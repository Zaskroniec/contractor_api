# frozen_string_literal: true

class Contract < ApplicationRecord
  monetize :wage_cents

  belongs_to :user
  belongs_to :company, optional: true

  def generate_guid
    return self if guid.present?

    self.guid = sprintf("N%05d", id)
    save
    reload
  end
end
