controllers_path = Rails.root.join("authentication/lib/authentication/ui/javascript/controllers")
controllers_path.glob("**/*_controller.js").each do |controller|
  name = controller.relative_path_from(controllers_path).to_s.remove(/\.js$/)
  pin "authentication/#{name}", to: name
end
