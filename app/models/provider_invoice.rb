class ProviderInvoice < ApplicationRecord
  belongs_to :user
  belongs_to :issuing, class_name: "Project"
  belongs_to :campaign
  has_many_attached :documents
  validates_presence_of :uuid
end
