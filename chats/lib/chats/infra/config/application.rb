Rails.application.config.paths.add 'chats/lib', load_path: true, autoload: true
Rails.application.config.paths['db/migrate'] << 'chats/lib/chats/infra/db/migrate'
Rails.application.config.paths['app/views'] << 'chats/lib'
Rails.application.config.importmap.paths << Rails.root.join('chats/lib/chats/infra/config/importmap.rb')
Rails.application.config.assets.paths << Rails.root.join("chats/lib/chats/ui/javascript/controllers")
# Rails.application.config.scenic.view_paths = [Rails.root.join('chats/lib/chats/infra/db/views')]
