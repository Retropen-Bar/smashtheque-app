require("@rails/ujs").start()
require("@rails/activestorage").start()
// require("channels")

import "bootstrap"
import "@fortawesome/fontawesome-free/css/all"
import "jquery"
import "jquery-ui/ui/widgets/sortable"
import "popper.js"

import "../src/shared/global_search"
import "../src/shared/images"
import "../src/shared/maps"
import "../src/shared/maps_autocomplete"
import "../src/shared/select2"
import "../src/shared/toastr"
import "../src/shared/toggles"

import "../src/application/filters"
import "../src/application/fullcalendar"
import "../src/application/global_search"
import "../src/application/tooltips"

// make images available
const images = require.context('../images', true)
const imagePath = (name) => images(name, true)

// require("trix")
// require("@rails/actiontext")
