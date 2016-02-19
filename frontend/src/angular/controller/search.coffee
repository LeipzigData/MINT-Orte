angular.module("app").controller "SearchController", ($scope, $routeParams, JsonData, NgMap, $timeout, $filter, localStorageService) ->
	console.log 'new SearchController'

	$scope.resetFilter= () ->

		$scope.option =
			all : true
			tech: false
			environment: false
			nature: false
			math: false
			computer: false
			job: false
			gta: false
			searchString: ""
			handicappedSuited: 0
			stadtteile:[]
	$scope.option = localStorageService.get("optionSave")
	if not $scope.option?
		$scope.resetFilter()
	#


	$scope.toggleStadtteil = (teil) ->
		if $scope.option.stadtteile.indexOf(teil)>-1
			$scope.option.stadtteile.splice($scope.option.stadtteile.indexOf(teil), 1)
		else
			$scope.option.stadtteile.push teil
	$scope.mapOpened= false
	$scope.select=(which) ->

		if which is "map"
			$scope.mapOpened = true
			NgMap.getMap().then (evtMap) ->
				$scope.center= [51.34, 12.37]
				$scope.myMap = evtMap
				$timeout ->
					google.maps.event.trigger($scope.myMap, 'resize')
				, 200
		else
			$scope.mapOpened = false
	$scope.updateMarkers = () ->
		$scope.markers= []
		if not $scope.filteredData? then return
		places={}
		for place in $scope.filteredData
			if place.Ort? and place.Ort.hasAddress? and place.Ort.hasAddress._label?
				if not places[place.Ort.hasAddress._label]?
					places[place.Ort.hasAddress._label]=$scope.markers.length
					$scope.markers.push
						places:[{
							name:place._label
							hasLogo: place.hasLogo if place.hasLogo?
							hasImage: place.hasImage if place.hasImage?
							_shortId: place._shortId
						}]
						lat: place.Ort.hasAddress['wgs84_pos#lat'] if place.Ort.hasAddress['wgs84_pos#lat']?
						long: place.Ort.hasAddress['wgs84_pos#long'] if place.Ort.hasAddress['wgs84_pos#long']?
						address: place.Ort.hasAddress._label
						id: place.id+""
				else
					$scope.markers[places[place.Ort.hasAddress._label]].places.push
						name:place._label
						hasLogo: place.hasLogo if place.hasLogo?
						hasImage: place.hasImage if place.hasImage?
						_shortId: place._shortId
					$scope.markers[places[place.Ort.hasAddress._label]].id+=":"+place.id

		$timeout ->
			try
				google.maps.event.trigger($scope.myMap, 'resize')
			catch error
			#	console.log "error:", error
		, 200
		# console.log " $scope.markers", $scope.markers
	$scope.updateFilter = () ->
		$scope.filteredData=$filter('jsonFilter')($scope.data, $scope.option)
		$scope.updateMarkers()
	$scope.showMarker = (marker, marker1) ->
		# console.log "showMarker", marker1
		$scope.myMap.customMarkers.overview.setVisible(true)
		$scope.currentMarker = marker1
		element1= this
		$timeout ->
			$scope.myMap.customMarkers.overview.setPosition(element1.getPosition())
		, 20
	$scope.hideMarker = () ->
		$scope.myMap.customMarkers.overview.setVisible(false)
	updateStadtteile = () ->
		stadtteile=[]
		$scope.stadtteileCount={}
		for element in $scope.data
			if not element.Ort? or not element.Ort.hasAddress? or not element.Ort.hasAddress.stadtteil? then continue
			if stadtteile.indexOf(element.Ort.hasAddress.stadtteil) is -1
				stadtteile.push element.Ort.hasAddress.stadtteil
				$scope.stadtteileCount[element.Ort.hasAddress.stadtteil] = 1
			else
				$scope.stadtteileCount[element.Ort.hasAddress.stadtteil]++
		$scope.stadtteile=stadtteile.sort()
	JsonData.getData (data) ->
		delete data.$promise
		delete data.$resolved

		$scope.data= data
		updateStadtteile()
		$scope.updateFilter()

	$scope.$watchCollection "option.stadtteile", (newValue, oldValue) ->
		updateAll()
		$scope.updateFilter()
		localStorageService.set("optionSave", $scope.option)
	$scope.$watchCollection "option", (newValue, oldValue) ->
		updateAll()
		$scope.updateFilter()
		localStorageService.set("optionSave", $scope.option)
	updateAll = () ->
		$scope.option.all = not ($scope.option.tech or $scope.option.math or $scope.option.environment or $scope.option.nature or $scope.option.computer or $scope.option.job)
