# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin 'beercss', to: 'https://cdn.jsdelivr.net/npm/beercss@3.4.13/dist/cdn/beer.min.js'
pin 'toastify-js' # @1.12.0pin "luxon" # @3.4.4
pin "picmo" # @5.8.5
pin "picmo/popup-picker", to: 'https://unpkg.com/@picmo/popup-picker@latest/dist/index.js?module', preload: true
pin "slim-select" # @2.8.1
pin "luxon" # @3.4.4
pin_all_from "app/javascript/controllers", under: "controllers"