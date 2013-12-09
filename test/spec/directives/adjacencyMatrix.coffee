'use strict'

describe 'Directive: adjacencyMatrix', () ->

  # load the directive's module
  beforeEach module 'votacoesCamaraApp'

  scope = {}

  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()

  it 'should make hidden element visible', inject ($compile) ->
    element = angular.element '<adjacency-matrix></adjacency-matrix>'
    element = $compile(element) scope
    expect(element.text()).toBe 'this is the adjacencyMatrix directive'
