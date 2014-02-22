var gulp = require('gulp');
var gutil = require('gulp-util');
var bower = require('gulp-bower');
var coffee = require('gulp-coffee');
var karma = require('gulp-karma');
var rename = require('gulp-rename');
var uglify = require('gulp-uglify');

var testFiles = [
  'bower_components/jquery/dist/jquery.js',
  'bower_components/bacon/dist/Bacon.js',
  'src/*.coffee',
  'test/*.coffee'
];

gulp.task('test', function() {
  return gulp.src(testFiles)
  .pipe(karma({
    browsers: ["PhantomJS"],
    configFile: 'karma.conf.js',
    action: 'run'
  }));
});

gulp.task('default', function() {
  gulp.src(testFiles)
    .pipe(karma({
      configFile: 'karma.conf.js',
      action: 'watch'
    }));
});

gulp.task('bower', function() {
  bower();
});

gulp.task('dist', function() {
  gulp.src('src/bacontrap.coffee')
    .pipe(coffee().on('error', gutil.log))
    .pipe(gulp.dest('./'))
    .pipe(uglify())
    .pipe(rename('bacontrap.min.js'))
    .pipe(gulp.dest('./'))
});
