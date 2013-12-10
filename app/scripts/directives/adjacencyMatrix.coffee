"use strict"

angular.module("votacoesCamaraApp")
  .directive("adjacencyMatrix", () ->
    svg = undefined
    margin = {top: 80, right: 0, bottom: 10, left: 130}
    width = 720
    height = 720
    
    x = d3.scale.ordinal().rangeBands([0, width])
    z = d3.scale.linear().domain([0, 4]).clamp(true)
    c = d3.scale.category10().domain(d3.range(10))
    color = d3.scale.quantile().domain([0.8, 1])
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
          matrix[link.source][link.source].z += link.value
          matrix[link.target][link.target].z += link.value
          matrix[link.source].name = nodes[link.source].name
          nodes[link.source].count += link.value
          nodes[link.target].count += link.value

        orders =
          count: d3.range(n).sort (a, b) -> nodes[b].count - nodes[a].count
        x.domain(orders.count)

        _draw(element, matrix)

    _draw = (element, matrix) ->
      svg = _drawSvg(element) if not svg?
      rows = _drawRows(svg, matrix)
      columns = _drawColumns(svg, matrix)

      rows.each(_colorizeRows)

    _drawSvg = (element) ->
      svgEl = d3.select(element).append("svg")
        .attr("width", width + margin.left + margin.right)
        .attr("height", height + margin.top + margin.bottom)
        .style("margin-left", "#{-margin.left} px")
      .append("g")
        .attr("transform", "translate(#{margin.left}, #{margin.top})")

      svgEl.append("rect")
         .attr("class", "background")
         .attr("width", width)
         .attr("height", height)

      svgEl

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
      element = d3.select(this).selectAll(".cell")
        .data(rows.filter((d) -> d.z))

      element.enter().append("rect")
        .attr("class", "cell")

      element.attr("x", (d) -> x(d.x) )
        .attr("width", x.rangeBand())
        .attr("height", x.rangeBand())
        .style("fill", (d) -> color(d.z))

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

    restrict: "E"
    scope:
      filepath: "="
    link: (scope, element, attrs) ->
      scope.$watch 'filepath', (filepath) ->
        render(element[0], filepath)
  )
