// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"
import * as bootstrap from "bootstrap"

// Allow to do direct upload with ActiveStorage and more
// https://edgeguides.rubyonrails.org/active_storage_overview.html#direct-uploads
import * as ActiveStorage from "@rails/activestorage"

ActiveStorage.start()