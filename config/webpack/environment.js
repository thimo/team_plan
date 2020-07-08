const { environment } = require("@rails/webpacker");
const { merge } = require("webpack-merge");
const webpack = require("webpack");
const { CleanWebpackPlugin } = require("clean-webpack-plugin");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const globImporter = require("node-sass-glob-importer");

// Add an additional plugin of your choosing : ProvidePlugin
environment.plugins.prepend(
  "Provide",
  new webpack.ProvidePlugin({
    $: "jquery",
    JQuery: "jquery",
    jquery: "jquery",
    "window.Tether": "tether",
    Popper: ["popper.js", "default"], // for Bootstrap 4
  })
);
environment.plugins.prepend("CleanWebpackPlugin", new CleanWebpackPlugin());

// Add less loader for bootstrap-datepicker
environment.loaders.append("less", {
  test: /\.less$/,
  use: [MiniCssExtractPlugin.loader, "css-loader", "less-loader"],
});

// Add glob (`/**/*`) parser to sass/scss files
const sassLoader = environment.loaders.get("sass").use.pop();
sassLoader.options.sassOptions = { importer: globImporter() };
environment.loaders.get("sass").use.push(sassLoader);

const aliasConfig = {
  resolve: {
    alias: {
      jquery: "jquery/src/jquery",
    },
  },
};

module.exports = merge(environment.toWebpackConfig(), aliasConfig);
