const path = require('path');

module.exports = {
  devtool: false,
  entry: './src/index.tsx',
  output: {
    filename: 'bundle.js',
    path: path.resolve(__dirname, 'dist')
  },
  resolve: {
    extensions: ['.ts', '.tsx', '.js']
  },
  module: {
    rules: [
      {
        test: /\.tsx?$/,
        use: 'ts-loader',
        exclude: /node_modules/
      },
      {
        test: /\.js$/,
        enforce: 'pre',
        exclude: /node_modules\/plotly\.js-dist/,
        use: ['source-map-loader'],
      }
    ]
  },
  ignoreWarnings: [
    {
      module: /plotly\.js-dist/,
      message: /Failed to parse source map/,
    },
  ],
  devServer: {
    static: path.join(__dirname, 'dist'),
    compress: true,
    port: 9000
  }
};