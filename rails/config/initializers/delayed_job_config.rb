Delayed::Worker.logger = Logger.new($stdout)
Delayed::Worker.max_run_time = 2.minutes

# To see exception notification emails for delayed job errors
module CustomFailedJob
  def handle_failed_job(job, error)
    super
    ExceptionNotifier.notify_exception(error, data: { job: })
  end
end

Delayed::Worker.prepend CustomFailedJob
