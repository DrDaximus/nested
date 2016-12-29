# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->

$(document).on 'page:change', ->

	Morris.Area
	  element: 'clicks_chart'
	  data: $('#clicks_chart').data('clicks')
	  xkey: 'day'
	  ykeys: [ 'day_count' ]
	  labels: [ 'Views' ]
	 	postUnits: [ ' views']
	 	goals: [$('#clicks_chart').data('total'), $('#clicks_chart').data('goal')]
	 	goalStrokeWidth: 2
	 	goalLineColors: ['Red', 'green']
	 	lineColors: ['blue']
	 	xLabelAngle: 45

	Morris.Dohnut
	  element: 'target_chart'
	  data: $('#clicks_chart').data('clicks')
	  xkey: 'day'
	  ykeys: [ 'day_count' ]
	  labels: [ 'Views' ]
	 	postUnits: [ ' views']
	 	lineColors: ['blue']
	 	xLabelAngle: 45

