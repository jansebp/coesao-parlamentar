"use strict"

angular.module("votacoesCamaraApp")
  .directive("navigationBar", ($state, parties) ->
    templateUrl: "views/directives/navigationBar.html"
    restrict: "E"
    link: (scope, element, attrs) ->
      scope.$on "$stateChangeSuccess", ->
        scope.party = parties[$state.params.party_id] || undefined
      scope.parties = parties
      scope.title = attrs.title
  )
