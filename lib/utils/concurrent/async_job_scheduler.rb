class AsyncJobScheduler
  def initialize(executor_service:)
    self.executor_service  = executor_service
  end

  def schedule(callable = nil, delay: 0.seconds, &block)
    unless !!callable ^ !!block
      raise ArgumentError, 'Either pass in a proc, or a block, but not both or none'
    end

    ActiveSupport::Dependencies.interlock.permit_concurrent_loads do
      future = Concurrent::Promises.delay_on(executor_service) do
        Rails.application.executor.wrap do
          sleep(delay)
          (callable || block).call
        end
      end

      future.on_rejection_using(executor_service) { |reason| raise StandardError.new(reason) }.touch
    end
  end

  def fulfilled_future(result = nil)
    Concurrent::Promises.fulfilled_future(result, executor_service)
  end

  def rejected_future(error)
    Concurrent::Promises.rejected_future(error)
  end

  def wrap
    ActiveSupport::Dependencies.interlock.permit_concurrent_loads do
      Rails.application.executor.wrap do
        yield
      end
    end
  end

  private

  attr_accessor :executor_service
end
