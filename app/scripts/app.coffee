"use strict"

angular.module("votacoesCamaraApp", ["ui.router", "ngRoute", "nvd3ChartDirectives"])
  .config ($stateProvider, $urlRouterProvider) ->
    $urlRouterProvider.otherwise("/")

    $stateProvider
      .state "main",
        url: "/"
        templateUrl: "views/main.html"
        controller: "MainCtrl"
      .state "party",
        url: "/:party_id"
        templateUrl: "views/party.html"
        controller: "PartyCtrl"
