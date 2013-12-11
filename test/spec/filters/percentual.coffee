'use strict'

describe 'Filter: percentual', () ->

  # load the filter's module
  beforeEach module 'votacoesCamaraApp'

  # initialize a new instance of the filter before each test
  percentual = {}
  beforeEach inject ($filter) ->
    percentual = $filter 'percentual'

  it 'should return the input prefixed with "percentual filter:"', () ->
    text = 'angularjs'
    expect(percentual text).toBe ('percentual filter: ' + text)
