"use strict"

angular.module("votacoesCamaraApp")
  .directive("navigationBar", ($state, parties) ->
    templateUrl: "views/directives/navigationBar.html"
    restrict: "E"
    link: (scope, element, attrs) ->
      scope.$on "$stateChangeSuccess", ->
        scope.party = parties[$state.params.party_id]
      scope.$watch "party", (party) ->
        $state.go("party", party_id: party.id) if party?
      scope.parties = parties
      scope.title = attrs.title
  )
