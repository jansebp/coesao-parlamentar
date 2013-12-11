"use strict"

angular.module("votacoesCamaraApp")
  .filter "roundedPercentual", ->
    (value) ->
      value = (value * 100) || 0
      absValue = Math.abs(value)
      decimalCases = if absValue > 100
                       0
                     else if absValue > 10
                       1
                     else
                       2

      "#{value.toFixed(decimalCases).replace(".", ",")}%"
