# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  $('#activityTable').dataTable(
    order: [[0, 'desc']]
  )
  $('#import_button').on 'click', ->
    $('#import_button a.btn').addClass('importing disabled')
