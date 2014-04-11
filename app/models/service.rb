class Service < ActiveRecord::Base
  
  default_scope { where(current: true) }
  
  scope :all_except, ->(service) { where.not(id: service) }
  
  belongs_to :certificate
  
  validates :address, presence: true
  validates :hostname, presence: true
  validates :port, presence: true
  
  before_save :service_is_current
  
  def service_is_current
    if current
      services=Service.all_except(self).where(address: address, 
                               hostname: hostname, 
                               port: port, 
                               current: true)
      services.update_all(current: false)
    end
  end
  
end
