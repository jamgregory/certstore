require 'socket'
require 'openssl'
require 'ipaddress'
require 'resolv'

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
    
    hostname = IPAddress.valid?(host) ? Resolv.getname(host) : host
    ipaddress = Resolv.getaddress hostname
    numeric_port = port.to_i
    service = Service.find_or_initialize_by({hostname: hostname, address: ipaddress, port: numeric_port, current: true})
    if service.scan
      service.save!
      puts "Created new Service #{service}"
    end
  end
  
  desc "Rescan known hosts"
  task rescan: :environment do
    Service.all.each do |service| 
      Rake::Task["ssl:scanhost"].reenable
      Rake::Task["ssl:scanhost"].invoke "#{service.hostname}:#{service.port}"
    end
  end
  
  desc "Mark a certificate as compromised"
  task compromised: :environment do
    # pass STDIN through a Certificate object so we get 
    keytext = STDIN.read.strip
    find_cert = Certificate.new(keytext: keytext)
    
    cert = Certificate.find_or_create_by(keytext: find_cert.keytext)
    puts "Created unknown certificate #{cert.serial}" if cert.new_record?
    cert.compromised=true
    cert.save!
    puts "Marked certificate #{cert.serial} as compromised"
  end

end
