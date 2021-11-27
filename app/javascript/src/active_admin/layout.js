import logoUrl from "../../images/smashtheque-short-black.svg";

let updateLayout = function () {
  $("h1#site_title").css("background-image", 'url("' + logoUrl + '")');
};

$(document).ready(updateLayout);
