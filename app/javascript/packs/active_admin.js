import "../stylesheets/active_admin"

require("@rails/activestorage").start()

import "@activeadmin/activeadmin"
import "arctic_admin"

import "@fortawesome/fontawesome-free/css/all"
import "jquery"
import "jquery-minicolors"
import "html5sortable"
import L from "leaflet"
import "leaflet.markercluster"
import "leaflet.featuregroup.subgroup"
import "select2"
import "select2/dist/js/i18n/fr"
import "tippy.js"

import "../src/shared/global_search"
import "../src/shared/images"
import "../src/shared/maps"
import "../src/shared/maps_autocomplete"
import "../src/shared/select2"
import "../src/shared/toastr"
import "../src/shared/toggles"

import "../src/active_admin/colors"
import "../src/active_admin/global_search"
import "../src/active_admin/layout"
import "../src/active_admin/time_zone"
import "../src/active_admin/tooltips"

require("trix")
require("@rails/actiontext")

// fix leaflet images
delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: require('leaflet/dist/images/marker-icon-2x.png'),
  iconUrl: require('leaflet/dist/images/marker-icon.png'),
  shadowUrl: require('leaflet/dist/images/marker-shadow.png'),
});
