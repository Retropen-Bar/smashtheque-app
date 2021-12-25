import { Calendar } from "@fullcalendar/core";
import timeGridPlugin from "@fullcalendar/timegrid";
import listPlugin from "@fullcalendar/list";

window.newPlanningCalendar = function (
  calendarEl,
  initialDate,
  levels,
  eventsDataUrl
) {
  function mobileCheck() {
    if (window.innerWidth >= 1200) {
      return false;
    } else {
      return true;
    }
  }

  let calendar = new Calendar(calendarEl, {
    plugins: [listPlugin, timeGridPlugin],
    themeSystem: "bootstrap",
    initialView: mobileCheck() ? "customListWeek" : "customTimeGrid",
    initialDate: initialDate,
    locale: "fr",
    firstDay: 1,
    height: "auto",
    headerToolbar: {
      start: "prev,next title",
      center: "",
      end: "",
    },
    validRange: function (nowDate) {
      const d = new Date();
      const day = d.getDay(),
        diff = d.getDate() - day + (day == 0 ? -6 : 1);
      const startDate = new Date(d.setDate(diff));
      const endDate = new Date();

      return {
        start: startDate,
        end: new Date(endDate.setDate(startDate.getDate() + 13)),
      };
    },
    viewDidMount: function (view) {
      var title = view.title;
      $(".fc-toolbar-chunk:first-child").prepend($(".planning-filters"));
    },
    views: {
      customTimeGrid: {
        type: "timeGrid",
        duration: { days: 7 },
        allDaySlot: false,
        slotMinTime: "08:00:00",
        slotDuration: "01:00:00",
        displayEventEnd: false,
        slotLabelFormat: {
          hour: "numeric",
          minute: "2-digit",
          omitZeroMinute: true,
          meridiem: "short",
        },
        dayHeaderContent: function (arg) {
          return calendar.formatDate(arg.date, { weekday: "long" });
        },
        eventDidMount: function (arg) {
          const eventParent = arg.el.parentElement;
          const hasNonZeroPercentages =
            eventParent.style.inset
              .match(/(\d+)%/g)
              ?.filter((match) => match !== "0%").length > 0;
          if (hasNonZeroPercentages) {
            eventParent.classList.add("with-real-inset");
          }
        },
      },
      customListWeek: {
        type: "listWeek",
        duration: { days: 7 },
        displayEventEnd: false,
        allDaySlot: false,
      },
    },
    windowResize: function (view) {
      if (window.innerWidth >= 1200) {
        calendar.changeView("customTimeGrid");
      } else {
        calendar.changeView("customListWeek");
      }
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

    for (var level of levels) {
      if (
        $("form#filters input#level-" + level).is(":checked") &&
        $(".dropdown-selected .level--" + level).length === 0
      ) {
        $("#filter-level .dropdown-selected").append(
          "<span class='level level--" + level + "'></span>"
        );
      } else if (!$("form#filters input#level-" + level).is(":checked")) {
        $(".dropdown-selected .level--" + level).remove();
      }
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
