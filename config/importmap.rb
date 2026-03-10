pin "application", preload: true
# Pin npm packages by running ./bin/importmap

pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
