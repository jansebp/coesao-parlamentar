"use strict"

angular.module("votacoesCamaraApp")
  .controller "PartyCtrl", ($scope, $routeParams, parties) ->
    $scope.party = parties[$routeParams.party_id]
    $scope.year = $routeParams.year
    $scope.$watch "year", (year) ->
      $scope.filepath = "data/matrix-#{$scope.party.id}-#{year}.json"
