# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).on 'turbolinks:load', ->
  matchParts = (term, text) ->
    if text.toUpperCase().indexOf(term.toUpperCase()) == 0
      return true
    false

  $('#team_member_players, #team_member_coaches, #team_member_trainers, #team_member_team_parents').select2 placeholder: "Selecteer leden", matcher: (params, data) ->
    if !params.term
      return data
    terms = params.term.split(' ')
    i = 0
    while i < terms.length
      if ! !terms[i]
        if data.text.toUpperCase().indexOf(terms[i].toUpperCase()) < 0
          return null
      i++
    data
  return
