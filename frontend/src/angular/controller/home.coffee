angular
.module("app")
.controller "HomeController", ($scope, JsonData) ->
	console.log 'new HomeController'

	JsonData.getData (data) ->
		$scope.baseData = data
