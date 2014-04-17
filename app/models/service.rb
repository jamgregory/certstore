require 'socket'
require 'openssl'
require 'timeout'

class Service < ActiveRecord::Base
  
  class ScanJob
    @queue = :service_scan
    
    def self.perform(host, port)
      hostname = IPAddress.valid?(host) ? Resolv.getname(host) : host
      ipaddress = Resolv.getaddress hostname
      numeric_port = port.to_i
      service = Service.find_or_initialize_by({hostname: hostname, address: ipaddress, port: numeric_port, current: true})
      Rails.logger.info "Scan started for #{host}:#{port}"
      if service.scan
        service.save!
        Rails.logger.info "Created new Service #{service}"
      end
      Rails.logger.debug "Scan finished for #{host}:#{port}"
    end
  end

  default_scope { order(:hostname) }
  scope :current, -> { where(current: true) }
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
          new_service.current = true
          service_cert = Certificate.find_or_create_by(keytext: peer_cert.keytext)
          write_attribute :certificate_id, service_cert.id
          Rails.logger.debug "Returning new service #{new_service}"
          return new_service.save!
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


