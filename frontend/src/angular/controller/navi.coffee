angular.module("app").controller "NaviController", ($scope, $routeParams, $controller, $rootScope, $location) ->
	$scope.activeMenu = ""
	# console.log "new NaviController"
	$scope.$on '$routeChangeStart', (next, current) ->
		$scope.activeMenu = ""
		if current.$$route?.originalPath.indexOf("/info") >= 0 # info
			$scope.activeMenu = "info"
		else if current.$$route?.originalPath.indexOf("/search") >= 0 # search
			$scope.activeMenu = "search"
		else if current.$$route?.originalPath.indexOf("/p") >= 0 # search
			$scope.activeMenu = "detail"
		else
			$scope.activeMenu = ""
