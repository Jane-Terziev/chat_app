Rails.application.routes_reloader.paths.unshift *Dir[File.join(Rails.root, '*', 'lib', '*', 'infra', 'config', 'routes.rb')]
