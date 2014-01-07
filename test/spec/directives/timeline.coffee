'use strict'

describe 'Directive: timeline', () ->

  # load the directive's module
  beforeEach module 'votacoesCamaraApp'

  scope = {}

  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()

  it 'should make hidden element visible', inject ($compile) ->
    element = angular.element '<timeline></timeline>'
    element = $compile(element) scope
    expect(element.text()).toBe 'this is the timeline directive'
