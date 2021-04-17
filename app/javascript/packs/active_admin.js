import "../stylesheets/active_admin"

require("@rails/ujs").start()
require("@rails/activestorage").start()

// to be removed?
import "@activeadmin/activeadmin"
import "arctic_admin"

import "jquery"
import "jquery.minicolors"
import "html5sortable"
import "leaflet"
import "leaflet.markercluster"
import "leaflet.featuregroup.subgroup"
import "select2"
import "select2/dist/js/i18n/fr"
import "tippy.js"
import "toastr"

import "../src/shared/global_search"
import "../src/shared/images"
import "../src/shared/maps"
import "../src/shared/maps_autocomplete"
import "../src/shared/select2"
import "../src/shared/toggles"

import "../src/active_admin/colors"
import "../src/active_admin/global_search"
import "../src/active_admin/time_zone"
import "../src/active_admin/tooltips"

require("trix")
require("@rails/actiontext")
