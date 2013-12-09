"use strict"

angular.module("votacoesCamaraApp")
  .directive("adjacencyMatrix", () ->
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
          nodes[link.source].count += link.value
          nodes[link.target].count += link.value

        orders =
          count: d3.range(n).sort (a, b) -> nodes[b].count - nodes[a].count
        x.domain(orders.count)

        _draw(element, matrix, nodes)

    _draw = (element, matrix, nodes) ->
      svg = d3.select(element).append("svg")
              .attr("width", width + margin.left + margin.right)
              .attr("height", height + margin.top + margin.bottom)
              .style("margin-left", "#{-margin.left} px")
            .append("g")
              .attr("transform", "translate(#{margin.left}, #{margin.top})")

      svg.append("rect")
         .attr("class", "background")
         .attr("width", width)
         .attr("height", height)

      rows = _drawRows(svg, matrix, nodes)
      _drawColumns(svg, matrix, nodes)

      rows.each(_colorizeRows)

    _drawRows = (svg, matrix, nodes) ->
      rows = _createGroups(svg, matrix, "row", (d, i) -> "translate(0, #{x(i)})")

      rows.append("line")
         .attr("x2", width)

      _drawLabels(rows, nodes)
         .attr("x", -6)
         .attr("text-anchor", "end")

      rows

    _drawColumns = (svg, matrix, nodes) ->
      columns = _createGroups(svg, matrix, "column", (d, i) -> "translate(#{x(i)})rotate(-90)")

      columns.append("line")
         .attr("x1", -width)

      _drawLabels(columns, nodes)
         .attr("x", 6)
         .attr("text-anchor", "start")

      columns

    _colorizeRows = (rows) ->
      d3.select(this).selectAll(".cell")
        .data(rows.filter((d) -> d.z))
        .enter().append("rect")
        .attr("class", "cell")
        .attr("x", (d) -> x(d.x) )
        .attr("width", x.rangeBand())
        .attr("height", x.rangeBand())
        .style("fill", (d) -> color(d.z))

    _createGroups = (svg, matrix, className, transform) ->
      svg.selectAll(".#{className}")
         .data(matrix)
      .enter().append("g")
         .attr("class", className)
         .attr("transform", transform)

    _drawLabels = (element, nodes) ->
      element.append("text")
            .attr("y", x.rangeBand() / 2)
            .attr("dy", ".32em")
            .text((d, i) -> nodes[i].name)

    restrict: "E"
    link: (scope, element, attrs) ->
      render(element[0], attrs.filepath)
  )
