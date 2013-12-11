"use strict"

angular.module("votacoesCamaraApp")
  .directive("adjacencyMatrix", () ->
    margin = {top: 80, right: 0, bottom: 10, left: 130}
    width = 720
    height = 720
    
    x = d3.scale.ordinal().rangeBands([0, width])
    color = d3.scale.quantile().domain([0.5, 1])
              .range(["#225ea8", "#41b6c4", "#a1dab4",  # Blueish
                      "#ffffcc",                        # White
                      "#fed98e", "#fe9929", "#cc4c02"]) # Redish

    render = (element, filepath) ->
      d3.json filepath, (data) ->
        matrix = []
        nodes = data.nodes
        n = nodes.length

        nodes.forEach (node, i) ->
          node.index = i
          node.count = 0
          matrix[i] = d3.range(n).map (j) -> { x: j, y: i, z: 0 }

        data.links.forEach (link) ->
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
      _drawRows(svg, matrix)
      _drawColumns(svg, matrix)

      svg.selectAll('.row').each(_colorizeRows)

    _drawRows = (svg, matrix) ->
      rows = _createGroups(svg, matrix, "row", (d, i) -> "translate(0, #{x(i)})")

      _drawLabels(rows)
         .attr("x", -6)
         .attr("text-anchor", "end")

      rows

    _drawColumns = (svg, matrix) ->
      columns = _createGroups(svg, matrix, "column", (d, i) -> "translate(#{x(i)})rotate(-90)")

      _drawLabels(columns)
         .attr("x", 6)
         .attr("text-anchor", "start")

      columns

    _colorizeRows = (rows) ->
      cells = d3.select(this).selectAll(".cell")
        .data(rows.filter((d) -> d.z))

      cells.enter().append("rect")
        .attr("class", "cell")

      cells.attr("x", (d) -> x(d.x) )
        .attr("width", x.rangeBand())
        .attr("height", x.rangeBand())
        .style("fill", (d) -> color(d.z))

      cells.exit().remove()

    _createGroups = (svg, matrix, className, transform) ->
      groups = svg.selectAll(".#{className}")
         .data(matrix, (d, i) -> d.name)
      g = groups.enter().append("g")
         .attr("class", className)
      groups.attr("transform", transform)
      groups.exit().remove()
      g

    _drawLabels = (element) ->
      element.append("text")
             .attr("y", x.rangeBand() / 2)
             .attr("dy", ".32em")
             .text((d) -> d.name)

    _buildScales = ->
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

    restrict: "E"
    templateUrl: "views/directives/adjacencyMatrix.html"
    scope:
      filepath: "="
    link: (scope, element, attrs) ->
      scope.width = width
      scope.height = height
      scope.margin = margin
      scope.scales = _buildScales()
      scope.$watch 'filepath', (filepath) ->
        render(element[0], filepath)
  )
