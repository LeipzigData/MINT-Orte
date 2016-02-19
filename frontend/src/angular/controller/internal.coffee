angular
.module("app")
.controller "InternalController", ($scope, JsonData, $timeout) ->
	$scope.JSON = JSON
	$scope.Object = Object
	JsonData.getData (data) ->
		$scope.RawData= data
	, false
	console.log 'new InternalController'
	$scope.countKey = (object1) ->
		return Object.keys(object1)
	$timeout () ->
		angular.element("body>div:eq(1)").removeClass('container').addClass('container-fluid')
	, 20
