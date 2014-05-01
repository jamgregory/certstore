require 'timeout'

class Scan < ActiveRecord::Base
  belongs_to :service
  belongs_to :certificate
    
  class ScanJob
    @queue = :service_scan
    
    def self.perform(id)
      scan = Scan.find_by(id: id).scan
    end
  end
  
  def scan
    begin
      update_attribute(:state, :in_progress)
      Rails.logger.debug "Scanning Certificate for #{service.hostname}:#{service.port}"
      Timeout::timeout(10) do 
        socket = TCPSocket.new service.hostname, service.port
        ssl_socket = OpenSSL::SSL::SSLSocket.new socket
        ssl_socket.connect
        Rails.logger.debug "Connected to #{service.hostname}:#{service.port}"
        old_certificate = certificate
        peer_cert = Certificate.new(keytext: ssl_socket.peer_cert.to_s)
        update_attributes(certificate: Certificate.find_or_create_by(keytext: peer_cert.keytext),
                          state: ((not old_certificate) or (peer_cert.keytext == old_certificate.keytext)) ? :completed : :unchanged,
                          message: 'Scan completed')
        Rails.logger.debug "Scan Completed"
      end
    rescue => e
      Rails.logger.error "Failed to update certificate #{e}"
      Rails.logger.error e.backtrace
      update_attributes(state: :failed, message: e)
    end
  end
  
end
