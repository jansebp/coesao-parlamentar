'use strict'

describe 'Filter: round', () ->

  # load the filter's module
  beforeEach module 'votacoesCamaraApp'

  # initialize a new instance of the filter before each test
  round = {}
  beforeEach inject ($filter) ->
    round = $filter 'round'

  it 'should return the input prefixed with "round filter:"', () ->
    text = 'angularjs'
    expect(round text).toBe ('round filter: ' + text)
