"use strict"

angular.module("votacoesCamaraApp")
  .controller "PartyCtrl", ($routeParams, $scope, $http, parties) ->
    $scope.party = parties[$routeParams.party_id]
    $scope.year = $routeParams.year

    $scope.$watch "year", (year) ->
      $scope.filepath = "data/#{$scope.party.id}-#{year}.json"
      $http.get($scope.filepath).success((graph) -> $scope.graph = graph)
