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
      puts "Attempting to get certificate for #{host}:#{port}"
    rescue
      raise "Please supply host:port"
    end
    
    begin
      socket = TCPSocket.new host, port
      hostname = IPAddress.valid?(host) ? Resolv.getname(host) : host
      ipaddress = socket.remote_address.ip_address
      numeric_port = port.to_i
    rescue => e
      raise "Could not connect to #{client}: #{e}"
    end
    
    begin
      ssl_socket = OpenSSL::SSL::SSLSocket.new socket
      ssl_socket.connect
      peer_cert = ssl_socket.peer_cert
      puts "Obtained certificate #{peer_cert.serial}"
    rescue => e
      raise "Could not obtain certificate from #{client}: #{e}"
    end
    
    begin
      cert = Certificate.find_or_create_by(keytext: peer_cert.to_s)
      puts "Created new Certificate" if cert.new_record?
      puts "Certificate serial: #{cert.serial}"
    rescue => e
      raise "Could not create Certificate: #{e}"
    end
    
    service = Service.find_or_create_by({hostname: hostname, address: ipaddress, port: numeric_port, certificate: cert, current: true})
    puts "Created new Service" if service.new_record?
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
