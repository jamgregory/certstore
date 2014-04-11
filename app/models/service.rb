class Service < ActiveRecord::Base
  belongs_to :certificate
  
  validates :address, presence: true
  validates :hostname, presence: true
  validates :port, presence: true
  
  before_save :service_is_current
  
  def service_is_current
    if current
      services=Service.find_by(address: address, 
                               hostname: hostname, 
                               port: port, 
                               current: true).where.not(id: id)
      services.update_all(current: false)
    end
  end
  
end
