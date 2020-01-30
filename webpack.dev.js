const webpack = require("webpack");
const merge = require("webpack-merge");
const common = require("./webpack.common.js");
const package = require("./package.json");

module.exports = merge(common, {
  mode: "development",
  plugins: [
    new webpack.BannerPlugin({
      banner: `/*!
Feathers UI v${package.version}
https://feathersui.com/

Copyright 2020 Bowler Hat LLC
Released under the MIT license
*/`,
      raw: true,
      entryOnly: true
    })
  ]
});
