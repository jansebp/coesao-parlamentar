"use strict"

angular.module("votacoesCamaraApp")
  .directive("adjacencyMatrix", () ->
    svg = undefined
    margin = {top: 10, right: 0, bottom: 10, left: 130}
    width = 720
    height = 720
    _scope = undefined
    
    transitionDuration = 2000
    transitionStartingPoint = height * 1.1

    x = d3.scale.ordinal().rangeBands([0, width])
    color = d3.scale.quantile().domain([0.4, 1])
              .range(["#225ea8", "#41b6c4", "#a1dab4",  # Blueish
                      "#ffffcc",                        # White
                      "#fed98e", "#fe9929", "#cc4c02"]) # Redish

    buildScales = ->
      quantiles = color.quantiles().slice()
      quantiles.unshift(0)
      quantiles.push(1)
      for quantile, i in quantiles
        previous = if i > 0
                     quantiles[i - 1]
                   else
                     quantile
        color: color(previous)
        threshold: quantile
        width: "#{(quantile - previous) * 100}%"

    reorder = undefined

    render = (element, graph, order) ->
      matrix = []
      parties_count = []
      parties_members = []
      nodes = graph.nodes
      n = nodes.length

      nodes.forEach (node, i) ->
        node.index = i
        node.count = 0
        matrix[i] = d3.range(n).map (j) -> { x: j, y: i, z: 0 }
        parties_count[node.partido] ||= 0
        parties_members[node.partido] ||= 0
        parties_members[node.partido] += 1

      graph.links.forEach (link) ->
        matrix[link.source][link.target].z += link.value
        matrix[link.source].name = nodes[link.source].name
        matrix[link.source].partido = nodes[link.source].partido
        nodes[link.source].count += link.value
        nodes[link.target].count += link.value
        
        parties_count[nodes[link.source].partido] += link.value / parties_members[nodes[link.source].partido]
        parties_count[nodes[link.target].partido] += link.value / parties_members[nodes[link.target].partido]

      orders =
        party: d3.range(n).sort (a, b) ->
          if (nodes[a].partido == nodes[b].partido)
            nodes[b].count - nodes[a].count
          else
            parties_count[nodes[b].partido] - parties_count[nodes[a].partido]
        count: d3.range(n).sort (a, b) -> nodes[b].count - nodes[a].count

      reorder = (order) ->
        x.domain(orders[order])
        _draw(element, matrix)

      reorder(order)

    _draw = (element, matrix) ->
      svg = d3.select(element).select("g")
      rows = _drawRows(matrix)

      _drawLabels(rows)

      svg.selectAll('.row').each(_colorizeRows)

    _drawRows = (matrix) ->
      transform = (d, i) -> "translate(0, #{x(i)})"
      exitTransform = (d, i) -> "translate(0, #{transitionStartingPoint})"
      rows = _createGroups(matrix, "row", transform, exitTransform)
      rows.attr("transform", "translate(0, #{-transitionStartingPoint})")

      rows

    _drawLabels = (element) ->
      element.append("text")
             .attr("y", x.rangeBand() / 2)
             .attr("dy", ".32em")
             .text((d) -> "#{d.name} (#{d.partido})")
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

    _createGroups = (matrix, className, transform, exitTransform) ->
      groups = svg.selectAll(".#{className}")
         .data(matrix, (d, i) -> "#{d.name}#{d.partido}") # FIXME: Adicionando o partido na chave faz com que, ao mudar de ano,
                                                          # parlamentares que trocaram de partido sumam e apareçam com outra linha.
                                                          # Seria massa ele só mudar o texto
      g = groups.enter().append("g")
         .attr("class", className)
      groups.transition().duration(transitionDuration).attr("transform", transform)
      groups.exit().transition().duration(transitionDuration).attr("transform", exitTransform).remove()
      g

    _mouseover = (p) ->
      svg.selectAll(".row").classed "active", (d) ->
        if d[0].y == p.y
          _scope.$apply ->
            _scope.activeCell.rowName = d.name
            _scope.activeCell.rowPartido = d.partido
            _scope.activeCell.value = p.z
          true
        else if d[0].y == p.x
          _scope.$apply ->
            _scope.activeCell.colName = d.name
            _scope.activeCell.colPartido = d.partido
          true

    _mouseout = (p) ->
      svg.selectAll(".row.active").classed("active", false)
      _scope.$apply ->
        _scope.activeCell = {}

    _setupSizesAndXScale = (scope, margin, element) ->
      margin.left = if scope.showLabels
                      130
                    else
                      0
      width = element.width() || width
      height = element.height() || height
      transitionStartingPoint = width * 1.1
      widthWithoutMargins = width - margin.left - margin.right
      scope.width = width
      scope.height = widthWithoutMargins + margin.bottom
      x.rangeBands([0, widthWithoutMargins])

    restrict: "E"
    templateUrl: "views/directives/adjacencyMatrix.html"
    scope:
      graph: "="
      activeCell: "="
      orderId: "="
      orders: "="
      showLabels: "="
    link: (scope, element, attrs) ->
      _scope = scope
      scope.margin = margin
      scope.scales = buildScales()
      scope.activeCell = {}
      scope.orders =
        count: { id: "count", label: "Coesão" }
        party: { id: "party", label: "Partido" }
      scope.$watch "orderId", (orderId) ->
        reorder(orderId) if orderId and reorder
      scope.$watch "graph", (graph) ->
        if graph
          _setupSizesAndXScale(scope, scope.margin, element)
          render(element[0], graph, scope.orderId)
  )
