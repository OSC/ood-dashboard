# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#

$ ->
  # Load the additional paths into the view after page load
  $.ajax
    url: 'favorite_paths'
    success: (data) ->
      $('#dropdown-files .dropdown-menu').append data.html
      return

  $("a[target=_blank]").on "click", (event) ->
    # open url using javascript, instead of following directly
    event.preventDefault()

    if(window.open($(this).attr("href")) == null)
      # link was not opened in new window, so display error msg to user
      html = $("#js-alert-danger-template").html()
      msg = "This link is configured to open in a new window, but it doesn't seem to have opened. " +
            "Please disable your popup blocker for this page and try again."

      # replace message in alert and add to main div of layout
      $("div[role=main]").prepend(html.split("ALERT_MSG").join(msg))
