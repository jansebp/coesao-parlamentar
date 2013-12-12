"use strict"

angular.module("votacoesCamaraApp")
  .filter "roundedPercentual", ->
    (value) ->
      value = (value * 100) || 0
      "#{Math.round(value)}%"
