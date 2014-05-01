require 'resque'
require 'digest/md5'

class JobQueue
  include ActiveModel::Model
  
  attr_accessor :name
  
  def name= name
    if Resque.queues.include?(name)
      @name = name
    else
      raise "Resque queue '#{name}' not found"
    end
  end
  
  def self.all
    Resque.queues.map { |q| JobQueue.new(name: q) }
  end
  
  def jobs
    Resque.peek(@name, 0, 0).map { |j| Job.new(args: j["args"], job_class: j['class'], queue: self) }
  end
  
  def jobs_waiting
    Resque.size(@name)
  end

end