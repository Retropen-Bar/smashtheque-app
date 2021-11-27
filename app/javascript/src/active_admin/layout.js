import logoUrl from "../../images/smashtheque-picto-dark.svg";

let updateLayout = function () {
  $("h1#site_title").css("background-image", 'url("' + logoUrl + '")');
};

$(document).ready(updateLayout);
