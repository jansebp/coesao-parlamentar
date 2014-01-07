"use strict"

angular.module("votacoesCamaraApp")
  .controller "PartyCtrl", ($state, $scope, $location, $http) ->
    $http.get("data/#{$state.params.party_id}.json").success (party) ->
      $scope.party = party
      $scope.showLabels = $scope.party.id == "mensaleiros"
      lastAvailableYear = $scope.party.years[$scope.party.years.length - 1]
      $scope.year = $location.search().year || lastAvailableYear
      $scope.orderId = $location.search().order_id || "party"
      $scope.medians = [
        key: "Medians"
        values: ([k, v] for own k, v of party.median)
      ]
      console.log($scope.medians)

    $scope.$watch "year", (year) ->
      return unless year?
      $scope.filepath = "data/#{$scope.party.id}-#{year}.json"
      $location.search("year", year)
      $http.get($scope.filepath).success (graph) ->
        $scope.graph = graph
        $scope.year = year

    $scope.$watch "orderId", (orderId) ->
      $location.search("order_id", orderId)
