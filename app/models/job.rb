require 'resque'

class Job
  include ActiveModel::Model
  
  attr_reader :args, :job_class, :queue
  
  def id
    # We have to manufacturer an ID as there is no such thing in 
    # resque. So we create and MD5 hash of the arguments and use
    # that. This will not be unique across multiple jobs with the
    # same arguments
  
    Digest::MD5.hexdigest(args.to_s) 
  end
  
  def destroy
    Resque.destroy(@queue.name, @job_class, @args)
  end
  
  def self.all
    
  end
  
  def self.find_by_id id
    # :( populate all jobs and find this one. Nasty
    
  end
  
  protected
  
  attr_writer :args, :job_class, :queue
  
end