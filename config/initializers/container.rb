Dir[File.join(Rails.root, 'lib', 'utils', 'events', '*.rb')].each do |file|
  require File.join(File.dirname(file), File.basename(file, File.extname(file)))
end

Dir[File.join(Rails.root, 'lib', 'utils', 'concurrent', '*.rb')].each do |file|
  require File.join(File.dirname(file), File.basename(file, File.extname(file)))
end

module App
  class Container < Dry::System::Container
    register('contract_validator') { ContractValidator.new }
    register('current_user_repository') { CurrentUserRepository }
    if Rails.env.test?
      register('events.client', RailsEventStore::Client.new(
        repository: NoOpEventRepository.new,
        mapper:     ToYAMLEventMapper.new,
        dispatcher: RubyEventStore::ComposedDispatcher.new(
          RailsEventStore::ImmediateAsyncDispatcher.new(scheduler: ImmediateActiveJobEventScheduler.new(serializer: YAML)),
          RailsEventStore::ImmediateAsyncDispatcher.new(scheduler: ImmediateEventScheduler.new(event_deserializer: YAML))
        )
      ))
    else
      register('events.client', RailsEventStore::Client.new(
        repository: NoOpEventRepository.new,
        mapper:     ToYAMLEventMapper.new,
        dispatcher: RubyEventStore::ComposedDispatcher.new(
          RailsEventStore::ImmediateAsyncDispatcher.new(scheduler: ActiveJobEventScheduler.new(serializer: YAML)),
          RailsEventStore::ImmediateAsyncDispatcher.new(
            scheduler: AsyncThreadEventScheduler.new(
              job_scheduler:      AsyncJobScheduler.new(
                executor_service: Concurrent::ThreadPoolExecutor.new(
                  min_threads:     1,
                  max_threads:     (ENV['BACKGROUND_THREADS'] || 5).to_i,
                  max_queue:       ENV['BACKGROUND_TASK_POOL_SIZE'].to_i,
                  fallback_policy: :caller_runs
                )
              ),
              event_deserializer: YAML
            )
          )
        )
      ))
    end

    register('events.publisher', memoize: true) { MetadataEventPublisher.new }
  end
end

Import = App::Container.injector

Rails.configuration.after_initialize do
  Dir[File.join(Rails.root, '*', 'lib', '*', 'infra', 'system', 'provider_source.rb')].each do |file|
    require File.join(File.dirname(file), File.basename(file, File.extname(file)))
  end
end