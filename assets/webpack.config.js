const path = require('path');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const UglifyJsPlugin = require('uglifyjs-webpack-plugin');
const OptimizeCSSAssetsPlugin = require('optimize-css-assets-webpack-plugin');
const CopyWebpackPlugin = require('copy-webpack-plugin');
const webpack = require("webpack");

const staticDir = path.join(__dirname, '.');
const destDir = path.join(__dirname, '../priv/static');
const publicPath = '/';

module.exports = (env, options) => ({
  entry: {
    app: [
      staticDir + "/styles/app.scss",
      staticDir + "/scripts/app.js"
    ]
  },
  output: {
    path: destDir,
    filename: 'js/[name].js',
    publicPath
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader'
        }
      },
      {
        test: /\.(css|scss)$/,
        use: ['style-loader', MiniCssExtractPlugin.loader, 'css-loader', 'sass-loader']
      },
      {
        test: /.(eot|svg|ttf|woff|woff2)$/,
        loader: "file-loader"
      },
      {
        test: /.(png|jpe?g|gif|svg)$/,
        loader: "file-loader",
        query: {
          name: "[name].[ext]?[hash]"
        }
      }
    ]
  },
  plugins: [
    new MiniCssExtractPlugin({ filename: "./css/app.css" }),
    new CopyWebpackPlugin([{ from: "./static" }]),
    new webpack.ProvidePlugin({
      $: "jquery",
      jQuery: "jquery",
      "window.jQuery": "jquery"
    }),
  ],
  watchOptions: {
    aggregateTimeout: 300,
    poll: 300
  }
});

if (process.env.NODE_ENV === "production") {
  module.exports.devtool = "#cheap-module-eval-source-map";

  module.exports.plugins = (module.exports.plugins || []).concat([
    new webpack.DefinePlugin({
      "process.env": {
        NODE_ENV: "production"
      }
    }),
    new webpack.optimize.UglifyJsPlugin({
      compress: {
        warnings: false
      }
    }),
    new OptimizeCssAssetsPlugin()
  ]);
}
