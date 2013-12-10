'use strict'

angular.module('votacoesCamaraApp')
  .controller 'MainCtrl', ($scope) ->
    $scope.filepaths = [
      "data/matrix-pt-2004.json"
      "data/matrix-pt-2005.json"
      "data/matrix-pt-2006.json"
      "data/matrix-pt-2007.json"
    ]
    $scope.filepath = $scope.filepaths[0]
