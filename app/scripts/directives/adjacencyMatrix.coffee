"use strict"

angular.module("votacoesCamaraApp")
  .directive("adjacencyMatrix", () ->
    margin = {top: 10, right: 0, bottom: 10, left: 130}
    width = 720
    height = 720
    
    transitionDuration = 2000
    transitionStartingPoint = height * 1.1

    x = d3.scale.ordinal().rangeBands([0, width])
    color = d3.scale.quantile().domain([0.5, 1])
              .range(["#225ea8", "#41b6c4", "#a1dab4",  # Blueish
                      "#ffffcc",                        # White
                      "#fed98e", "#fe9929", "#cc4c02"]) # Redish

    buildScales = ->
      colors = color.range()
      domain = color.domain()
      min = domain[0]
      max = domain[1]
      length = colors.length
      step = (max - min) / length
      scaleWidth = 100 / length
      for c, i in colors
        color: c
        threshold: min + i*step
        width: scaleWidth

    render = (element, graph) ->
      matrix = []
      nodes = graph.nodes
      n = nodes.length

      nodes.forEach (node, i) ->
        node.index = i
        node.count = 0
        matrix[i] = d3.range(n).map (j) -> { x: j, y: i, z: 0 }

      graph.links.forEach (link) ->
        matrix[link.source][link.target].z += link.value
        matrix[link.source].name = nodes[link.source].name
        nodes[link.source].count += link.value
        nodes[link.target].count += link.value

      orders =
        count: d3.range(n).sort (a, b) -> nodes[b].count - nodes[a].count
      x.domain(orders.count)

      _draw(element, matrix)

    _draw = (element, matrix) ->
      svg = d3.select(element).select("g")
      rows = _drawRows(svg, matrix)
      _drawColumns(svg, matrix)

      _drawLabels(rows)

      svg.selectAll('.row').each(_colorizeRows)

    _drawRows = (svg, matrix) ->
      transform = (d, i) -> "translate(0, #{x(i)})"
      exitTransform = (d, i) -> "translate(0, #{transitionStartingPoint})"
      rows = _createGroups(svg, matrix, "row", transform, exitTransform)
      rows.attr("transform", "translate(0, #{-transitionStartingPoint})")

      rows

    _drawColumns = (svg, matrix) ->
      transform = (d, i) -> "translate(#{x(i)})rotate(-90)"
      exitTransform = (d, i) -> "translate(#{transitionStartingPoint})rotate(-90)"
      columns = _createGroups(svg, matrix, "column", transform, exitTransform)
      columns.attr("transform", "translate(#{-transitionStartingPoint})rotate(-90)")

      columns

    _drawLabels = (element) ->
      element.append("text")
             .attr("y", x.rangeBand() / 2)
             .attr("dy", ".32em")
             .text((d) -> d.name)
             .attr("x", -6)
             .attr("text-anchor", "end")

    _colorizeRows = (rows) ->
      cells = d3.select(this).selectAll(".cell")
        .data(rows.filter((d) -> d.z))

      cells.enter().append("rect")
        .attr("class", "cell")

      cells.attr("x", (d) -> x(d.x))
        .attr("width", x.rangeBand())
        .attr("height", x.rangeBand())
        .style("fill", (d) -> color(d.z))
        .on("mouseover", _mouseover)
        .on("mouseout", _mouseout)

      cells.exit().remove()

    _createGroups = (svg, matrix, className, transform, exitTransform) ->
      groups = svg.selectAll(".#{className}")
         .data(matrix, (d, i) -> d.name)
      g = groups.enter().append("g")
         .attr("class", className)
      groups.transition().duration(transitionDuration).attr("transform", transform)
      groups.exit().transition().duration(transitionDuration).attr("transform", exitTransform).remove()
      g

    _mouseover = (p) ->
      d3.selectAll("svg .row").classed("active", (d) ->
        d[0].y == p.y or d[0].y == p.x
      )

    _mouseout = (p) ->
      d3.selectAll("svg .row").classed("active", false)

    restrict: "E"
    templateUrl: "views/directives/adjacencyMatrix.html"
    scope:
      graph: "="
    link: (scope, element, attrs) ->
      scope.width = width
      scope.height = height
      scope.margin = margin
      scope.scales = buildScales()
      scope.$watch 'graph', (graph) ->
        render(element[0], graph) if graph
  )
