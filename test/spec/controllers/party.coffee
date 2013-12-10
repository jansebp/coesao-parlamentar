'use strict'

describe 'Controller: PartyCtrl', () ->

  # load the controller's module
  beforeEach module 'votacoesCamaraApp'

  PartyCtrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    PartyCtrl = $controller 'PartyCtrl', {
      $scope: scope
    }

  it 'should attach a list of awesomeThings to the scope', () ->
    expect(scope.awesomeThings.length).toBe 3
