"use strict"

angular.module("votacoesCamaraApp")
  .filter "percentual", ->
    (value) ->
      "#{value * 100}%"
