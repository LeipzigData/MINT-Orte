#angular.module("app.data", [])
angular.module "app", [
	'ngRoute'
	'ui.bootstrap'
	'ngResource'
	'app.services'
	'ngAnimate'
	'angular-loading-bar'
	'ngMap'
	'LocalStorageModule'
]
.config ($routeProvider) ->
	$routeProvider
	#HomeURLs
	.when '/',
		templateUrl: "home.html"
		controller: "HomeController"
	.when '',
		templateUrl: "home.html"
		controller: "HomeController"
	#Search URLs
	.when '/search',
		templateUrl: "search.html"
		controller: "SearchController"
	#Institution
	.when '/p/:placeId',
		templateUrl: "place.html"
		controller: "PlaceController"
	.when '/info',
		templateUrl: "info.html"
		controller: "InfoController"
	.when '/internal',
		templateUrl: "internal.html"
		controller: "InternalController"
	.otherwise
		redirectTo: "/"
angular.module 'app.services', []
