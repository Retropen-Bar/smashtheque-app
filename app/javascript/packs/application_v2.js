import "trix/dist/trix.css";

require("@rails/ujs").start();
require("@rails/activestorage").start();
// require("channels")

import "bootstrap";
import "@fortawesome/fontawesome-free/css/all";
import "jquery";
import "jquery-ui/ui/widgets/sortable";
import "popper.js";

import "../src/shared/images";
import "../src/shared/maps";
import "../src/shared/maps_autocomplete";
import "../src/shared/select2";
import "../src/shared/global_search";
import "../src/shared/time_zone"
import "../src/shared/toastr";
import "../src/shared/toggles";
import "../src/shared/tooltips";

import "../src/application_v2/global_search";
import "../src/application_v2/filters";
import "../src/application_v2/fullcalendar";
import "../src/application_v2/modals";
import "../src/application_v2/nested_forms";
import "../src/application_v2/slideout";
import "../src/application_v2/scrollactive";
import "../src/application_v2/vue";

require("trix");
require("@rails/actiontext");
