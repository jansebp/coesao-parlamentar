"use strict"

angular.module("votacoesCamaraApp")
  .controller "PartyCtrl", ($state, $scope, $location, $http, parties) ->
    $scope.party = parties[$state.params.party_id]
    lastAvailableYear = $scope.party.years[$scope.party.years.length - 1]
    $scope.year = $location.search().year || lastAvailableYear

    $scope.$watch "year", (year) ->
      $scope.filepath = "data/#{$scope.party.id}-#{year}.json"
      $location.search("year", year)
      $http.get($scope.filepath).success((graph) ->
        $scope.graph = graph
        $scope.year = year
      )
