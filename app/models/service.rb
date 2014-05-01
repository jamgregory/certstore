require 'socket'
require 'openssl'
require 'timeout'

class Service < ActiveRecord::Base
  
  has_many :scans
  
  def scan
    Scan.create(service: self, state: :waiting).scan
  end

  default_scope { order(:hostname) }
  scope :current, -> { where(current: true) }
  scope :current_not_retired, -> { where(current: true, retired: false) }
  scope :not_retired, -> { where(retired: false) }
  scope :all_except, ->(service) { where.not(id: service) }
    
  validates :address, presence: true
  validates :hostname, presence: true
  validates :port, presence: true
  
  def last_scan(state = :completed)
    scans.where(state: state).order(:updated_at).last
  end
  
  def certificate
    last_scan ? last_scan.certificate : nil
  end
  
end


