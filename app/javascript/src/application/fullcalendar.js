import { Calendar } from "@fullcalendar/core";
import timeGridPlugin from "@fullcalendar/timegrid";

window.newPlanningCalendar = function (
  calendarEl,
  initialDate,
  levels,
  eventsDataUrl
) {
  let calendar = new Calendar(calendarEl, {
    plugins: [timeGridPlugin],
    themeSystem: "bootstrap",
    initialView: "customTimeGrid",
    initialDate: initialDate,
    locale: "fr",
    firstDay: 1,
    height: "auto",
    headerToolbar: false,
    views: {
      customTimeGrid: {
        type: "timeGrid",
        duration: { days: 7 },
        allDaySlot: false,
        slotMinTime: "08:00:00",
        slotDuration: "01:00:00",
        slotLabelFormat: {
          hour: "numeric",
          minute: "2-digit",
          omitZeroMinute: true,
          meridiem: "short",
        },
        dayHeaderContent: function (arg) {
          return calendar.formatDate(arg.date, { weekday: "long" });
        },
      },
    },
    events: function (fetchInfo, successCallback, failureCallback) {
      var params = fetchInfo;
      params.by_level_in = [];
      for (var level of levels) {
        if ($("form#filters input#level-" + level).is(":checked")) {
          params.by_level_in.push(level);
        }
      }
      if (params.by_level_in.length < 1) {
        delete params["by_level_in"];
      }
      params.by_size_geq = $("form#filters select#size-min").val();
      params.by_size_leq = $("form#filters select#size-max").val();
      params.per = 1000;
      $.ajax({
        dataType: "json",
        url: eventsDataUrl,
        data: params,
        success: successCallback,
        error: failureCallback,
      });
    },
    eventClick: function (arg) {
      arg.jsEvent.preventDefault(); // don't let the browser navigate
      $.get(arg.event.extendedProps.modal_url, function (html) {
        $("#planning-modal").html(html).modal();
      });
    },
  });
  calendar.render();
  $("form#filters").on("change", "input, select", function (e) {
    calendar.refetchEvents();

    if ($("form#filters input[id*=level-]").is(":checked")) {
      $("#filter-level").addClass("active");
    } else {
      $("#filter-level").removeClass("active");
    }

    if (
      $("form#filters select#size-min").val() ||
      $("form#filters select#size-max").val()
    ) {
      $("#filter-size").addClass("active");
      $("#filter-size .dropdown-selected").html(
        $("form#filters select#size-min").find(":selected").text() +
          " - " +
          $("form#filters select#size-max").find(":selected").text()
      );
    } else {
      $("#filter-size").removeClass("active");
      $("#filter-size .dropdown-selected").html("");
    }
  });
};
