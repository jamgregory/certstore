require 'socket'
require 'openssl'
require 'timeout'

class Service < ActiveRecord::Base
  
  default_scope { where(current: true).order(:hostname) }
  
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
  
  def scan
    begin
      Rails.logger.debug "Scanning Certificate for #{hostname}:#{port}"
      socket = TCPSocket.new hostname, port
      Timeout::timeout(10) do 
        ssl_socket = OpenSSL::SSL::SSLSocket.new socket
        ssl_socket.connect
        peer_cert = Certificate.new(keytext: ssl_socket.peer_cert.to_s)
    
        if not certificate or peer_cert.keytext != certificate.keytext
          Rails.logger.info "New certificate found for #{hostname}:#{port}: #{peer_cert.serial}"
          # We found a new certificate - create a new service for it
          new_service = self.dup
          new_service.certificate = Certificate.find_or_create_by(keytext: peer_cert.keytext)
          Rails.logger.debug "Returning new service #{new_service}"
          return new_service.save
        else
          Rails.logger.debug "Unchanged certificate for #{hostname}:#{port}"
          return false
        end
      end
    rescue => e
      raise "Could not update certificate #{e}"
    end
  end
  
end
