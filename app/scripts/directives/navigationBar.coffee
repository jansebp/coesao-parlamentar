"use strict"

angular.module("votacoesCamaraApp")
  .directive("navigationBar", (parties) ->
    routeFor = (party) ->
      lastYear = party.years[party.years.length - 1]
      "#/#{party.id}/#{lastYear}"

    templateUrl: "views/directives/navigationBar.html"
    restrict: "E"
    link: (scope, element, attrs) ->
      scope.parties = parties
      scope.title = attrs.title
      scope.routeFor = routeFor
  )
