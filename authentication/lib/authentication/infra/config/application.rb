Rails.application.config.paths.add 'authentication/lib', load_path: true, autoload: true
Rails.application.config.paths['db/migrate'] << 'authentication/lib/authentication/infra/db/migrate'
Rails.application.config.paths['app/views'] << 'authentication/lib'
Rails.application.config.importmap.paths << Rails.root.join('authentication/lib/authentication/infra/config/importmap.rb')
Rails.application.config.assets.paths << Rails.root.join("authentication/lib/authentication/ui/javascript/controllers")