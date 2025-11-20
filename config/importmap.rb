# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "chart.js/auto", to: "https://cdn.jsdelivr.net/npm/chart.js@4.4.4/auto/auto.js"
pin "chart.js", to: "https://cdn.jsdelivr.net/npm/chart.js@4.4.4/dist/chart.js"
pin "chartjs-adapter-date-fns", to: "https://cdn.jsdelivr.net/npm/chartjs-adapter-date-fns@3.0.0/dist/chartjs-adapter-date-fns.esm.js"
pin "date-fns", to: "https://cdn.jsdelivr.net/npm/date-fns@3.6.0/+esm"
pin "@kurkle/color", to: "https://cdn.jsdelivr.net/npm/@kurkle/color@0.3.2/+esm"
