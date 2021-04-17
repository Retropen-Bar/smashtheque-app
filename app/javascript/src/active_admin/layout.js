import logoUrl from '../../images/smashtheque-64.png'

let updateLayout = function() {
  $('h1#site_title').css(
    'background-image',
    'url("' + logoUrl + '")'
  );
};

$(document).ready(updateLayout);
