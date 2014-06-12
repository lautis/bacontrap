gulp = require 'gulp'
gutil = require 'gulp-util'
coffee = require 'gulp-coffee'
source = require 'vinyl-source-stream'
browserify = require 'browserify'
watchify = require 'watchify'
karma = require('karma').server
rename = require 'gulp-rename'
uglify = require 'gulp-uglify'
wrap = require 'gulp-wrap-umd'
fs = require 'fs'
_ = require 'lodash'

karmaConfiguration =
  browsers: ['PhantomJS']
  frameworks: ['mocha']
  files: [
    'test/test.js'
  ]

gulp.task 'watch', (done) ->
  rebundle = ->
    bundler.bundle()
      .pipe(source('test.js'))
      .pipe(gulp.dest('./test/'))


  bundler = watchify('./test/bacontrap_spec.coffee')
  bundler.on('update', rebundle)
  rebundle()
  karma.start(_.assign({}, karmaConfiguration, singleRun: false), done)

gulp.task 'test-build', ->
  browserify('./test/bacontrap_spec.coffee').bundle()
    .pipe(source('test.js'))
    .pipe(gulp.dest('./test/'))

gulp.task 'test', ['test-build'], (done) ->
  karma.start(_.assign({}, karmaConfiguration, singleRun: true), done)

gulp.task 'test-browser', ['test-build'], (done) ->
  karma.start(_.assign({}, karmaConfiguration, singleRun: true, browsers: ['Chrome', 'Firefox']), done)

gulp.task 'dist', ->
  gulp.src('src/bacontrap.coffee')
    .pipe(coffee().on('error', gutil.log))
    .pipe(wrap(
      namespace: 'Bacontrap'
      template: fs.readFileSync('umd-template.jst')
      deps: [
        {name: 'baconjs', globalName: 'Bacon', amdName: 'bacon'},
        {name: 'jquery', globalName: 'jQuery', amdName: 'jquery'}
      ]
    ))
    .pipe(gulp.dest('./'))
    .pipe(uglify())
    .pipe(rename('bacontrap.min.js'))
    .pipe(gulp.dest('./'))

gulp.task 'default', ['test', 'dist']
