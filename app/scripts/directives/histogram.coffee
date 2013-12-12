"use strict"

angular.module("votacoesCamaraApp")
  .directive("histogram", ($filter) ->
    restrict: "E"
    templateUrl: "views/directives/histogram.html"
    scope:
      graph: "="
    link: (scope, element, attrs) ->
      scope.tickFormat = $filter("roundedPercentual")
      scope.$watch "graph", (graph) ->
        return unless graph
        values = (link.value for link in graph.links)
        histogram = d3.layout.histogram()
                      .bins([0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1, 1])
        
        values = ([h.x, h.y/values.length] for h in histogram(values))
        scope.data = [
          {
            "values": values
          }
        ]
  )
