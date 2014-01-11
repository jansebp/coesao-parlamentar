"use strict"

angular.module("votacoesCamaraApp", ["ui.router", "ngRoute", "nvd3ChartDirectives"])
  .config ($stateProvider, $urlRouterProvider) ->
    $urlRouterProvider.otherwise("/")

    $stateProvider
      .state "main",
        url: "/"
        templateUrl: "views/main.html"
        controller: "MainCtrl"
      .state "team",
        url: "/equipe"
        templateUrl: "views/team.html"
      .state "party",
        url: "/:party_id"
        templateUrl: "views/party.html"
        controller: "PartyCtrl"
      # FIXME: Esse state deveria ser filho do party (i.e. party.widget), mas
      # quando coloquei assim, o templateUrl era ignorado. Possivelmente um bug
      # do ui-router.
      .state "widget",
        url: "/:party_id/widget"
        views:
          header: {}
          footer: {}
          "":
            templateUrl: "views/party.widget.html"
            controller: "PartyCtrl"
