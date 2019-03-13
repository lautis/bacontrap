gulp = require 'gulp'
gutil = require 'gulp-util'
coffee = require 'gulp-coffee'
source = require 'vinyl-source-stream'
browserify = require 'browserify'
watchify = require 'watchify'
karma = require('karma').server
rename = require 'gulp-rename'
uglify = require 'gulp-uglify'
fs = require 'fs'
_ = require 'lodash'
header = require 'gulp-header'
coffeeify = require 'coffeeify'

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
  browserify('./test/bacontrap_spec.coffee').transform(coffeeify).bundle()
    .pipe(source('test.js'))
    .pipe(gulp.dest('./test/'))

gulp.task 'test', ['test-build'], (done) ->
  karma.start(_.assign({}, karmaConfiguration, singleRun: true), done)

gulp.task 'test-browser', ['test-build'], (done) ->
  karma.start(_.assign({}, karmaConfiguration, singleRun: true, browsers: ['Chrome', 'Firefox']), done)

gulp.task 'dist', ->
  version = JSON.parse(fs.readFileSync('package.json')).version
  copyright = "/*\n  Bacontrap v#{version}\n\n  " + fs.readFileSync('LICENSE.txt').toString().split('\n').join('\n  ').replace(/\s+$/gm, '\n') + "\n*/"
  gulp.src('src/bacontrap.coffee')
    .pipe(coffee(bare: true))
    .pipe(header(copyright))
    .pipe(gulp.dest('./'))
    .pipe(uglify())
    .pipe(header("/* Bacontrap v#{version}. Copyright 2013 Ville Lautanala. https://raw.githubusercontent.com/lautis/bacontrap/master/LICENSE.txt */"))
    .pipe(rename('bacontrap.min.js'))
    .pipe(gulp.dest('./'))

gulp.task 'default', ['test', 'dist']
