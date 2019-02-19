path = require 'path'

webpack = require 'webpack'
nodeExternals = require 'webpack-node-externals'

BuildEnvironment = process.env.NODE_ENV or 'development'
if BuildEnvironment not in ['development', 'production']
  throw new Error "Undefined environment #{BuildEnvironment}"

# handles output filename for js and css
outputFilename = (ext) ->
  d = "[name].#{ext}"
  p = "[name].min.#{ext}"
  return
    development: d
    production: p
    
# set output filenames
WebPackOutputFilename = outputFilename 'js'
CssOutputFilename = outputFilename 'css'

WebPackOutput =
  filename: WebPackOutputFilename[BuildEnvironment]
  path: path.resolve 'build'
  library: 'bumblr'
  libraryTarget: 'umd'

coffeeLoaderRule =
  test: /\.coffee$/
  loader: 'coffee-loader'
  options:
    transpile:
      presets: ['env']
    sourceMap: true

common_plugins = []
extraPlugins = []
WebPackOptimization = {}

if BuildEnvironment is 'production'
  UglifyJsPlugin = require 'uglifyjs-webpack-plugin'
  WebPackOptimization.minimizer = [
    new UglifyJsPlugin
      sourceMap: true
      uglifyOptions:
        compress:
          warnings: true
        warnings: true
    ]
AllPlugins = common_plugins.concat extraPlugins


WebPackConfig =
  mode: BuildEnvironment
  optimization: WebPackOptimization
  entry:
    app: './src/main.coffee'
  output: WebPackOutput
  plugins: AllPlugins
  externals: [nodeExternals()]
  module:
    rules: [
      coffeeLoaderRule
    ]
  resolve:
    extensions: [".wasm", ".mjs", ".js", ".json", ".coffee"]
    alias:
      tbirds: 'tbirds/src'
  stats:
    colors: true
    modules: false
    chunks: true
    #maxModules: 9999
    #reasons: true


if BuildEnvironment is 'development'
  WebPackConfig.devtool = 'source-map'
      
module.exports = WebPackConfig
