class JobQueuesController < ApplicationController

  # GET /queues
  # GET /queues.json
  def index
    @job_queues = JobQueue.all
  end
end