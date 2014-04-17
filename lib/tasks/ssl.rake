require 'socket'
require 'openssl'
require 'ipaddress'
require 'resolv'
require 'resque'

namespace :ssl do
  
  desc "Scan a host:port for an SSL Certificate"
  task :scanhost, [:client] => [:environment] do |t, args|
    begin
      client=args[:client]
      host,port=client.split ':'
      Rails.logger.info "Attempting to get certificate for #{host}:#{port}"
    rescue
      raise "Please supply host:port"
    end
    
    Rails.logger.debug "Queuing ScanJob task for #{host}:#{port}"
    Resque.enqueue(Service::ScanJob,host,port)
    Rails.logger.debug "Job queued"

  end
  
  desc "Rescan known hosts"
  task rescan: :environment do
    Service.current.each do |service|
      Resque.enqueue(Service::ScanJob, service.hostname, service.port)
    end
  end
  
  desc "Mark a certificate as compromised"
  task compromised: :environment do
    # pass STDIN through a Certificate object so we get 
    keytext = STDIN.read.strip
    find_cert = Certificate.new(keytext: keytext)
    
    cert = Certificate.find_or_create_by(keytext: find_cert.keytext)
    Rails.logger.info "Created unknown certificate #{cert.serial}" if cert.new_record?
    cert.compromised=true
    cert.save!
    Rails.logger.info "Marked certificate #{cert.serial} as compromised"
  end

end
