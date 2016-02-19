var gulp = require('gulp');
var del = require('del');
var less = require("gulp-less");

var jade = require('gulp-jade');
var bower = require('gulp-bower');
var templateCache = require('gulp-angular-templatecache');
var ngAnnotate = require("gulp-ng-annotate");
var htmlify = require('gulp-angular-htmlify');
var concat = require("gulp-concat");
var coffee = require("gulp-coffee");
var sourcemaps = require("gulp-sourcemaps");
var gutil = require("gulp-util");
var coffeelint = require('gulp-coffeelint');
var livereload = require('gulp-livereload');
var uglify = require("gulp-uglify");
var gls = require('gulp-live-server');

var paths = {
	distDir: 'dist',
	angularTemplates: 'src/angular/views/*.jade',
	angularApp: ['src/angular/app/*.coffee', 'src/angular/directive/*.coffee', 'src/angular/controller/*.coffee' ],
	jadeTemplate: 'src/jade/*.jade',
	bower: 'dist/vendor',
	lessFile: "src/less/style.less",
	config: require('./config.json')
};

gulp.task('bower', ['clean-bower'],  function() {
  return bower()
    .pipe(gulp.dest(paths.bower))
});

gulp.task('coffee-lint',  function(){
gulp.src(paths.angularApp)
    .pipe(coffeelint())
	.pipe(coffeelint.reporter())

});
gulp.task('angular-app', ['coffee-lint'],  function(){
	var coffeestream = coffee({bare:true})
	coffeestream.on('error', gutil.log)
	appscripts = gulp.src(paths.angularApp)
	.pipe(sourcemaps.init())
	.pipe(coffeestream)
    .pipe(ngAnnotate())
	.pipe(uglify())
	.pipe(concat("app.min.js"))
	.pipe(sourcemaps.write())
	.pipe(gulp.dest(paths.distDir+"/js"))
	.pipe(livereload());
	})
gulp.task("build-less", function(){

		gulp.src(paths.lessFile)
		.pipe(sourcemaps.init())
		.pipe(less({
			compress: true,
			paths: [
				"./dist/vendor/bootstrap/less",
				"./dist/vendor/fontawesome/less"
			]
		}))
		.pipe(sourcemaps.write())
		.pipe(gulp.dest(paths.distDir+"/css"))
})
gulp.task('angular-tmpl', function(){
	gulp.src(paths.angularTemplates)
	.pipe(jade().on('error',function(err){
		console.log(err);
	}))
	.pipe(htmlify())
	.pipe(sourcemaps.init())
	.pipe(templateCache({
		root: "",
		standalone: false,
		module: "app"
	}))
	.pipe(uglify())
	.pipe(concat("app.tmpl.min.js"))
	.pipe(gulp.dest(paths.distDir+"/js"))
	.pipe(livereload());

});
gulp.task('clean-bower', function() {
  return del(paths.bower);
});
gulp.task('clean-jade', function() {
  return del(paths.distDir+'/index.html');
});

gulp.task('jade',  ['clean-jade'], function() {
	gulp.src(paths.jadeTemplate)
    .pipe(jade({
		locals: paths.config
	}).on('error',function(err){
		console.log(err);
	}))
    .pipe(gulp.dest(paths.distDir))
	.pipe(livereload());
});

gulp.task('watch-files', function() {
	//livereload.listen();
	var server = gls.static('dist', 3000);
	server.start();
	gulp.watch(paths.jadeTemplate, ['jade']);
	gulp.watch(paths.angularApp, ['angular-app']);
	gulp.watch(paths.angularTemplates, ['angular-tmpl']);
	gulp.watch(paths.lessFile, ['build-less']);
	gulp.watch('bower.json', ['bower']);
	gulp.watch(['dist/js/*.js','dist/index.html', 'dist/css/*.css'], function (file) {
		server.notify.apply(server, [file]);
	});

});

gulp.task('watch',['watch-files', 'default'])
gulp.task('rebuild', [ 'jade', 'bower', 'angular-tmpl', 'build-less', 'angular-app']);
gulp.task('default', [ 'jade', 'angular-tmpl', 'angular-app', 'build-less']);
