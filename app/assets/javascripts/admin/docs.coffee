$ ->
  $('#tooltip-right').tooltip(placement: "right")
  $('#tooltip-left').tooltip(placement: "left")
  $('#tooltip-top').tooltip(placement: "top")
  $('#tooltip-bottom').tooltip(placement: "bottom")

  $('#popover-right').popover(placement: "right")
  $('#popover-left').popover(placement: "left")
  $('#popover-top').popover(placement: "top")
  $('#popover-bottom').popover(placement: "bottom")

  $("#small-calendar").datepicker()
  $('#ui-datepicker-div').hide()
  $(":radio").uniform()
  $(":checkbox").uniform()
  $("input[type='checkbox'], input[type='radio']").uniform()

  
  $(".chzn-select").chosen()

  #input validation tooltips
  $('.input-error').tooltip()
  $('.input-warning').tooltip()
  $('.input-success').tooltip()

  #piety charts
  $(".line").peity("line")
  $(".bar").peity("bar")

  #faq list
  new Faq($(".faq-list"))

$ ->
  $('#thumbs a').touchTouch()


  # knob circle stats
  orange = "#FF9609"
  green = "#80B031"
  blue = "#0096DB"
  red = "#f54f6c"
  yellow = "#fec643"

  $(".circle-stat.red").knob
    fgColor: red
    skin: "tron"
    width: 110
    height: 110
    readOnly: true
    thickness: 0.2

  $(".circle-stat.orange").knob
    fgColor: orange
    skin: "tron"
    width: 110
    height: 110
    readOnly: true
    thickness: 0.2

  $(".circle-stat.yellow").knob
    fgColor: yellow
    skin: "tron"
    width: 110
    height: 110
    readOnly: true
    thickness: 0.2

  $(".circle-stat.blue").knob
    fgColor: blue
    skin: "tron"
    width: 110
    height: 110
    readOnly: true
    thickness: 0.2

  $(".circle-stat.green").knob
    fgColor: green
    skin: "tron"
    width: 110
    height: 110
    readOnly: true
    thickness: 0.2