angular.module("app").controller "PlaceController", ($scope, $routeParams, JsonData, $anchorScroll, NgMap, $timeout) ->
	console.log 'new PlaceController'
	$scope.JSON = JSON
	$scope.mapOpened = false
	$scope.select=(which) ->
		if which is "map"
			$scope.mapOpened = true
			NgMap.getMap().then (evtMap) ->
				$scope.myMap = evtMap
				$timeout ->
					# console.log "reload"
					google.maps.event.trigger($scope.myMap, 'resize')
					if $scope.place.Ort.hasAddress['wgs84_pos#lat']?
						$scope.center= $scope.place.Ort.hasAddress['wgs84_pos#lat']+','+$scope.place.Ort.hasAddress['wgs84_pos#long']
					else
						$scope.center= $scope.place.Ort.hasAddress._label
				, 200
		else
			$scope.mapOpened = false
	JsonData.getData (data) ->
		$scope.data= data
		# console.log data
		for element in $scope.data when element._shortId is $routeParams.placeId
			$scope.place = element
			# console.log $scope.place
	$anchorScroll()
