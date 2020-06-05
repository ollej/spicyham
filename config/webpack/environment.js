const { environment } = require('@rails/webpacker');

// resolve-url-loader must be used before sass-loader
environment.loaders.get('sass').use.splice(-1, 0, {
  loader: 'resolve-url-loader'
});

const webpack = require('webpack');
environment.plugins.prepend('Provide',
  new webpack.ProvidePlugin({
    $: 'jquery',
    jQuery: 'jquery'
  })
);

environment.loaders.append('expose', {
  test: require.resolve('jquery'),
  use: [
    {
      loader: 'expose-loader',
      options: '$'
    }, {
      loader: 'expose-loader',
      options: 'jQuery'
    }
  ]
});

module.exports = environment;
