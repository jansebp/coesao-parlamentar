"use strict"

angular.module("votacoesCamaraApp")
  .directive "timeline", ($filter) ->
    templateUrl: "views/directives/timeline.html"
    restrict: "E"
    scope:
      values: "="
    link: (scope, element, attrs) ->
      scope.tickFormat = $filter("roundedPercentual")
      scope.tooltipContent = (key, x, y) ->
        "#{y} em #{x}"
