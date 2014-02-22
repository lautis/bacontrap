// Karma configurationka
module.exports = function(config) {
  config.set({
    basePath: '',
    frameworks: ['mocha', 'browserify'],
    files: [],
    exclude: [],
    reporters: ['progress'],
    port: 9876,
    colors: true,
    logLevel: config.LOG_INFO,
    autoWatch: true,
    browsers: ['Chrome'],
    captureTimeout: 60000,
    singleRun: false,
    browserify: {
      extensions: ['.coffee'],
      transform: ['coffeeify'],
      watch: true,
      debug: true
    },
    preprocessors: {
      '**/*.coffee': ['coffee'],
      'test/**/*': ['browserify']
    },

    coffeePreprocessor: {
      // options passed to the coffee compiler
      options: {
        bare: false,
        sourceMap: true
      },
      // transforming the filenames
      transformPath: function(path) {
        return path.replace(/\.coffee$/, '.js');
      }
    }
  });
};
