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
    OpenSSL::X509::Certificate.new(keytext)
  end
  
  def serial
    certificate.serial.to_s(16)
  end
  
  def not_before
    certificate.not_before
  end
  
  def not_after
    certificate.not_after
  end
  
  def issuer
    certificate.issuer.to_s
  end
  
  def subject
    certificate.subject.to_s
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
  
end
