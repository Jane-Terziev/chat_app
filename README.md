# README

A simple chat app that supports attachments and emojis. The app is a modular monolith that sends messages real time 
using turbo streams.

- Ruby version
3.2.2
- Rails version
7.1
- Database
postgresql
- Message broker Redis
- Background worker Sidekiq

## Getting Started

The recommended way to get started is with docker.

    docker-compose run --rm app rake db:create db:migrate
    docker-compose run --rm app rake assets:precompile

    # Create Users to sign in with devise
    docker-compose run --rm app rails c

```ruby
User.create!(id: SecureRandom.uuid, email: "test1@example.com", password: "test123", first_name: "Name1", last_name: "LastName1")
User.create!(id: SecureRandom.uuid, email: "test2@example.com", password: "test123", first_name: "Name2", last_name: "LastName2")
```

    docker-compose up

## Project Architecture
The project uses the dry.rb gems, initializing an App Container in *config/initializers/container.rb*. Each feature is 
defined in the *root/feature_name*folder. Each feature folder contains the following structure:
    
    feature_name
        lib
            feature_name
                app
                domain
                infra
                ui
        spec

## App
The app folder contains all our services and response dtos. All our business logic goes here. The service methods call a 
Model method to modify the data, save, and publish all the events registered by the Aggregate Root. The models that we 
modify here need to be defined as an Aggregate Root. The Aggregate Root Models hold an array of domain events that are 
registered by the model methods. The pub/sub comes from the rails_event_store gem.

## Domain
The domain folder holds all our models and events that are registered by the model methods. The models should implement
methods that are related to data modifications. If the model inherits from the AggregateRoot class, it can hold an array
of domain events, which on successful save, the services uses to publish all the events. The events are sent to Redis, 
and the background worker reads from there and maps them to a Listener. The mapping is defined in 
infra/system/provider_source.

## Infra
This folder holds all the files related to the infrastructure, such as application configs, routing configs, database 
migrations, importmap javascript pins, and a provider_source file, which registers our models and services into the app 
container. This makes our feature a bootable component, which is automatically booted in the provider_source file on the 
line:
```ruby
App::Container.register_provider(:chats, from: :chats)
App::Container.start(:chats)
```

This will give us access to all the registered dependencies in the lines above, and we can use dependency injection in 
the following way:
```ruby
include Import[chat_service: 'chats.chat_service', chat_repository: 'chats.chat_repository']
```

### NOTE
There is an issue with the dry-system gem and the dependency injection in the controllers, because of the change in 
change on the ruby 3+ initialize method. Because of that we have to define a custom strategy, located in 
lib/utils/injection/controller_resolve_strategy, and add the strategy to the auto injector. This is defined in 
config/initializers/dependency_injection. When using dependency injection in the controller, use the following syntax:
```ruby
include Import.inject[chat_service: 'chats.chat_service', chat_repository: 'chats.chat_repository']
```
 
When using dependency injection in the Listeners, use the following syntax:

```ruby 
include Import.active_job[chat_service: 'chats.chat_service', chat_repository: 'chats.chat_repository]
```

## Ui
The Ui folder holds everything related to the presentation layer. This includes validation classes, controllers, 
listeners, assets. It serves as an access point to our module, either through a controller, or an event listener.

### Note
If you have custom javascript controllers in a feature module, you need to include it in 2 places in order for the 
controller to be registered and compiled from the asset pipeline.

    # app/assets/config/manifest.js
    //= link_tree ../../../chats/lib/chats/ui/javascript/controllers .js
  
    # app/javascript/controllers/index.js
    eagerLoadControllersFrom("chats", application)