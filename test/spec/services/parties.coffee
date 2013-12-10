'use strict'

describe 'Service: parties', () ->

  # load the service's module
  beforeEach module 'votacoesCamaraApp'

  # instantiate service
  parties = {}
  beforeEach inject (_parties_) ->
    parties = _parties_

  it 'should do something', () ->
    expect(!!parties).toBe true
