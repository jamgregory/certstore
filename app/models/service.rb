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
  scope :not_retired, ->(state = :completed) { includes(:scans).joins(:scans).where("scans.state = '#{state}'").order("scans.created_at DESC").group("services.id").where(retired: false) }
  scope :all_except, ->(service) { where.not(id: service) }
    
  validates :address, presence: true
  validates :hostname, presence: true
  validates :port, presence: true
  
  def last_scan(state = :completed)
    # state ? scans.where(state: state).order(:updated_at).last : scans.order(:updated_at).last
    #scans.to_a.select { |scan| scan.state == state }.max_by(&:updated_at)
    scans.last
  end
  
  def certificate
    last_scan ? last_scan.certificate : nil
  end
  
end


