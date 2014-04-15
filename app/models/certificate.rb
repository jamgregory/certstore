require 'openssl'

class Certificate < ActiveRecord::Base
  validates :keytext, uniqueness: true
  validates :keytext, presence: true
  validate :validate_x509_certificate
    
  def validate_x509_certificate
    begin
      OpenSSL::X509::Certificate.new keytext
    rescue => e
      errors.add :keytext, "Invalid X509 Certificate in keytext: #{e}"
    end
  end
  
  def keytext= keytext
    # do a bit of tidying up, remove superfluous whitespace
    write_attribute(:keytext,keytext.strip.split("\n").map {|line| line.rstrip}.join("\n")).gsub /^$\n/,''
  end
  
  def certificate
    keytext ? OpenSSL::X509::Certificate.new(keytext) : nil
  end
  
  def serial
    certificate ? certificate.serial.to_s(16) : ''
  end
  
  def not_before
    certificate ? certificate.not_before : nil
  end
  
  def not_after
    certificate ? certificate.not_after : nil
  end
  
  def issuer
    certificate ? certificate.issuer.to_s : ''
  end
  
  def subject
    certificate ? certificate.subject.to_s : ''
  end
  
  def cn
    subject.sub /.*CN=([^\/$]*).*/, '\1'
  end
  
  class SubjectAlternateName < String
    def type
      self.split(':').first
    end
    
    def value
      self.split(':').last
    end
  end
  
  def subject_alt_names
    return unless certificate
    san_exts = certificate.extensions.select do |e| 
      e.oid == 'subjectAltName'
    end
    
    sans = san_exts.map do |e|
      e.value.split(', ').map do |v|
        SubjectAlternateName.new v
      end
    end
    
    sans.flatten
  end
  
  def services_using current=true
    Service.where(current: current, certificate: self)
  end
  
  def expires_soon?
    not_after < (Time.now+90.days)
  end
  
  def expired?
    not_after.past?
  end
  
  def in_use?
    services_using.length > 0
  end
  
end
