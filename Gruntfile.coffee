module.exports = (grunt) ->
  grunt.loadNpmTasks 'grunt-bower-task'
  grunt.loadNpmTasks 'grunt-browserify'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-mocha'

  grunt.registerTask 'default', ['browserify', 'mocha']

  grunt.initConfig
    bower:
      install: {}
      options:
        copy: false
    browserify:
      'tmp/tests.js': ['src/**/*.coffee', 'test/**/*.coffee']
      options:
        transform: ['coffeeify']
    coffee:
      main:
        files: [
          'bacontrap.js': 'src/bacontrap.coffee'
        ]
    mocha:
      index: ['test/index.html']
      options:
        run: true
    watch:
      watch:
        files: ['src/**/*.coffee', 'test/**/*.coffee'],
        tasks: ['browserify', 'mocha']
