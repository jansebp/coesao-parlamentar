(function(){"use strict";angular.module("votacoesCamaraApp",["ui.router","ngRoute","nvd3ChartDirectives"]).config(["$stateProvider","$urlRouterProvider",function(a,b){return b.otherwise("/"),a.state("main",{url:"/",templateUrl:"views/main.html",controller:"MainCtrl"}).state("team",{url:"/equipe",templateUrl:"views/team.html"}).state("party",{url:"/:party_id",templateUrl:"views/party.html",controller:"PartyCtrl"}).state("widget",{url:"/:party_id/widget",views:{header:{},footer:{},"":{templateUrl:"views/party.widget.html",controller:"PartyCtrl"}}})}])}).call(this),function(){"use strict";angular.module("votacoesCamaraApp").controller("MainCtrl",function(){})}.call(this),function(){"use strict";angular.module("votacoesCamaraApp").directive("adjacencyMatrix",function(){var a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t;return g=void 0,d={top:10,right:0,bottom:10,left:200},j=720,c=720,s=void 0,h=2e3,i=1.1*c,k=d3.scale.ordinal().rangeBands([0,j]),b=d3.scale.quantile().domain([.4,1]).range(["#225ea8","#41b6c4","#a1dab4","#ffffcc","#fed98e","#fe9929","#cc4c02"]),a=function(){var a,c,d,e,f,g,h;for(e=b.quantiles().slice(),e.unshift(0),e.push(1),h=[],a=f=0,g=e.length;g>f;a=++f)d=e[a],c=a>0?e[a-1]:d,h.push({color:b(c),threshold:d,width:""+100*(d-c)+"%"});return h},f=void 0,e=function(a,b,c){var d,e,g,h,i,j;return d=[],i=[],j=[],g=b.nodes,e=g.length,g.forEach(function(a,b){var c,f;return a.index=b,a.count=0,d[b]=d3.range(e).map(function(a){return{x:a,y:b,z:0}}),i[c=a.party]||(i[c]=0),j[f=a.party]||(j[f]=0),j[a.party]+=1}),b.links.forEach(function(a){return d[a.source][a.target].z+=a.value,d[a.source].name=g[a.source].name,d[a.source].party=g[a.source].party,g[a.source].count+=a.value,g[a.target].count+=a.value,i[g[a.source].party]+=a.value/j[g[a.source].party],i[g[a.target].party]+=a.value/j[g[a.target].party]}),h={party:d3.range(e).sort(function(a,b){return g[a].party===g[b].party?g[b].count-g[a].count:i[g[b].party]-i[g[a].party]}),count:d3.range(e).sort(function(a,b){return g[b].count-g[a].count})},f=function(b){return k.domain(h[b]),n(a,d)},f(c)},n=function(a,b){var c;return g=d3.select(a).select("g"),c=p(b),o(c),g.selectAll(".row").each(l)},p=function(a){var b,c,d;return d=function(a,b){return"translate(0, "+k(b)+")"},b=function(){return"translate(0, "+i+")"},c=m(a,"row",d,b),c.attr("transform","translate(0, "+-i+")"),c},o=function(a){return a.append("text").attr("dy",".32em").text(function(a){return""+a.name+" ("+a.party+")"}).attr("x",-6).attr("text-anchor","end"),g.selectAll("text").transition().duration(h).attr("y",k.rangeBand()/2)},l=function(a){var c;return c=d3.select(this).selectAll(".cell").data(a.filter(function(a){return a.z})),c.enter().append("rect").attr("class","cell"),c.attr("x",function(a){return k(a.x)}).attr("width",k.rangeBand()).attr("height",k.rangeBand()).style("fill",function(a){return b(a.z)}).on("mouseover",r).on("mouseout",q),c.exit().remove()},m=function(a,b,c,d){var e,f;return f=g.selectAll("."+b).data(a,function(a){return""+a.name+a.party}),e=f.enter().append("g").attr("class",b),f.transition().duration(h).attr("transform",c),f.exit().transition().duration(h).attr("transform",d).remove(),e},r=function(a){return g.selectAll(".row").classed("active",function(b){return b[0].y===a.y?(s.$apply(function(){return s.activeCell.rowName=b.name,s.activeCell.rowPartido=b.party,s.activeCell.value=a.z}),!0):b[0].y===a.x?(s.$apply(function(){return s.activeCell.colName=b.name,s.activeCell.colPartido=b.party}),!0):void 0})},q=function(){return g.selectAll(".row.active").classed("active",!1),s.$apply(function(){return s.activeCell={}})},t=function(a,b,d){var e;return b.left=a.showLabels?200:0,j=d.width()||j,c=d.height()||c,i=1.1*j,e=j-b.left-b.right,a.width=j,a.height=e+b.bottom,k.rangeBands([0,e])},{restrict:"E",templateUrl:"views/directives/adjacencyMatrix.html",scope:{graph:"=",activeCell:"=",orderId:"=",orders:"=",showLabels:"="},link:function(b,c){return s=b,b.margin=d,b.scales=a(),b.activeCell={},b.orders={count:{id:"count",label:"Coesão"},party:{id:"party",label:"Partido"}},b.$watch("orderId",function(a){return a&&f?f(a):void 0}),b.$watch("graph",function(a){return a?(t(b,b.margin,c),e(c[0],a,b.orderId)):void 0})}}})}.call(this),function(){"use strict";var a={}.hasOwnProperty;angular.module("votacoesCamaraApp").controller("PartyCtrl",["$state","$scope","$location","$http",function(b,c,d,e){return e.get("data/"+b.params.party_id+".json").success(function(b){var e,f,g;return c.party=b,c.showLabels="mensaleiros"===c.party.id,f=c.party.years[c.party.years.length-1],c.year=d.search().year||f,c.orderId=d.search().order_id||"party",c.quartiles=[{key:"Primeiro quartil",values:function(){var c,d;c=b.quartiles,d=[];for(e in c)a.call(c,e)&&(g=c[e],d.push([e,g[0]]));return d}()},{key:"Mediana",values:function(){var c,d;c=b.quartiles,d=[];for(e in c)a.call(c,e)&&(g=c[e],d.push([e,g[1]]));return d}()},{key:"Segundo quartil",values:function(){var c,d;c=b.quartiles,d=[];for(e in c)a.call(c,e)&&(g=c[e],d.push([e,g[2]]));return d}()}],c.deputados=[{key:"Deputados",values:function(){var c,d;c=b.deputados,d=[];for(e in c)a.call(c,e)&&(g=c[e],d.push([e,g]));return d}()}],c.sessions=[{key:"Totais",values:function(){var c,d;c=b.sessions,d=[];for(e in c)a.call(c,e)&&(g=c[e],d.push([e,g.total]));return d}()},{key:"Filtradas",values:function(){var c,d;c=b.sessions,d=[];for(e in c)a.call(c,e)&&(g=c[e],d.push([e,g.filtered]));return d}()}]}),c.$watch("year",function(a){return null!=a?(c.filepath="data/"+c.party.id+"-"+a+".json",d.search("year",a),e.get(c.filepath).success(function(b){return c.graph=b,c.year=a})):void 0}),c.$watch("orderId",function(a){return d.search("order_id",a)})}])}.call(this),function(){"use strict";angular.module("votacoesCamaraApp").constant("parties",[{id:"pt",label:"PT"},{id:"pmdb",label:"PMDB"},{id:"psdb",label:"PSDB"},{id:"psd",label:"PSD"},{id:"pp",label:"PP"},{id:"pr",label:"PR"},{id:"psb",label:"PSB"},{id:"dem",label:"DEM"},{id:"pdt",label:"PDT"},{id:"ptb",label:"PTB"},{id:"psc",label:"PSC"},{id:"pcdob",label:"PCdoB"},{id:"pps",label:"PPS"},{id:"pv",label:"PV"},{id:"prb",label:"PRB"},{id:"ptdob",label:"PTdoB"},{id:"pen",label:"PEN"},{id:"psol",label:"PSOL"},{id:"pmn",label:"PMN"},{id:"prp",label:"PRP"},{id:"phs",label:"PHS"},{id:"psl",label:"PSL"},{id:"ptc",label:"PTC"},{id:"prtb",label:"PRTB"},{id:"pan",label:"PAN"},{id:"pmr",label:"PMR"},{id:"pfl",label:"PFL"},{id:"pros",label:"PROS"},{id:"ptn",label:"PTN"},{id:"pl",label:"PL"},{id:"pstu",label:"PSTU"},{id:"pst",label:"PST"},{id:"sdd",label:"SDD"},{id:"prona",label:"PRONA"},{id:"ppl",label:"PPL"},{id:"ppb",label:"PPB"},{id:"psdc",label:"PSDC"},{id:"mensaleiros",label:"Mensaleiros"}])}.call(this),function(){"use strict";angular.module("votacoesCamaraApp").directive("histogram",["$filter",function(a){return{restrict:"E",templateUrl:"views/directives/histogram.html",scope:{graph:"="},link:function(b){return b.tickFormat=a("roundedPercentual"),b.tooltipContent=function(a,b,c){return c},b.$watch("graph",function(a){var c,d,e,f;return a?(f=function(){var b,c,d,f;for(d=a.links,f=[],b=0,c=d.length;c>b;b++)e=d[b],f.push(e.value);return f}(),d=d3.layout.histogram().bins([0,.1,.2,.3,.4,.5,.6,.7,.8,.9,1,1]),f=function(){var a,b,e,g;for(e=d(f),g=[],a=0,b=e.length;b>a;a++)c=e[a],g.push([c.x,c.y/f.length]);return g}(),b.data=[{values:f}]):void 0})}}}])}.call(this),function(){"use strict";angular.module("votacoesCamaraApp").filter("roundedPercentual",function(){return function(a){return a=100*a||0,""+Math.round(a)+"%"}})}.call(this),function(){"use strict";angular.module("votacoesCamaraApp").directive("navigationBar",["$state","parties",function(a,b){return{templateUrl:"views/directives/navigationBar.html",restrict:"E",link:function(c,d,e){return c.$on("$stateChangeSuccess",function(){return c.party=b[a.params.party_id]||void 0}),c.parties=b,c.title=e.title}}}])}.call(this),function(){"use strict";angular.module("votacoesCamaraApp").directive("timeline",["$filter",function(a){return{templateUrl:"views/directives/timeline.html",restrict:"E",scope:{values:"="},link:function(b,c,d){return b.tickFormat="true"===d.showAsPercentual?a("roundedPercentual"):function(a){return a},b.tooltipContent=function(a,b,c){return""+c+" em "+b}}}}])}.call(this);