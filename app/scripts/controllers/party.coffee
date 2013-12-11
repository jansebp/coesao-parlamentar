"use strict"

angular.module("votacoesCamaraApp")
  .controller "PartyCtrl", ($routeParams, $scope, $http, parties) ->
    $scope.party = parties[$routeParams.party_id]
    $scope.year = $routeParams.year
    $scope.$watch "year", (year) ->
      filepath = "data/#{$scope.party.id}-#{year}.json"
      $http.get(filepath).success((graph) -> $scope.graph = graph)
