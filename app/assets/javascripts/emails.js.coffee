updateProgressBar = ->
  $.getScript "/emails/status/" + gon.job_id
  setTimeout updateProgressBar, 5000

$(".emails.index").ready ->
  $('.email-body-long').readmore({  speed: 75, maxHeight: 150})
  setTimeout updateProgressBar, 5000
