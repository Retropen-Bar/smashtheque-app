const { environment } = require('@rails/webpacker')

const jquery = require('./plugins/jquery')

environment.plugins.prepend('jquery', jquery)

environment.loaders.get('sass').use.splice(-1, 0, {
  loader: 'resolve-url-loader',
  options: {
    attempts: 1
  }
});

module.exports = environment
