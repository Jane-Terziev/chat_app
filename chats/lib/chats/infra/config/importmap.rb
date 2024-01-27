controllers_path = Rails.root.join("chats/lib/chats/ui/javascript/controllers")
controllers_path.glob("**/*_controller.js").each do |controller|
  name = controller.relative_path_from(controllers_path).to_s.remove(/\.js$/)
  pin "chats/#{name}", to: name
end
