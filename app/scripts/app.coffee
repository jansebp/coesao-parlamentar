'use strict'

angular.module('votacoesCamaraApp', ['ui.router'])
  .config ($stateProvider, $urlRouterProvider) ->
    $urlRouterProvider.otherwise('/')

    $stateProvider
      .state 'root',
        url: '/'
        templateUrl: 'views/main.html'
        controller: 'MainCtrl'
