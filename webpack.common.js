const path = require("path");

module.exports = {
  entry: {
    "feathersui-openfl": "./lib/feathers/index.js"
  },
  devtool: "source-map",
  output: {
    path: path.resolve(__dirname, "dist"),
    library: "feathers",
    libraryTarget: "umd",
    filename: "feathersui-openfl.js"
  },
  externals: {
    howler: {
      commonjs: "howler",
      commonjs2: "howler",
      amd: "howler",
      root: "window"
    },
    pako: {
      commonjs: "pako",
      commonjs2: "pako",
      amd: "pako",
      root: "pako"
    }
  }
};
