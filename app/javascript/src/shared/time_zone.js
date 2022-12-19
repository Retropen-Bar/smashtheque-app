if (Intl) {
  var timezone = Intl.DateTimeFormat().resolvedOptions().timeZone;
  document.cookie = 'time_zone=' + timezone + ';path=/';
}
