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
    openfl: {
      commonjs: "openfl",
      commonjs2: "openfl",
      amd: "openfl",
      root: "openfl"
    },
    motion: {
      commonjs: "motion",
      commonjs2: "motion",
      amd: "motion",
      root: "motion"
    }
  }
};
