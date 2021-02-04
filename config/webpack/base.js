const { webpackConfig, merge } = require("@rails/webpacker");

const aliasConfig = {
  resolve: {
    alias: {
      jquery: "jquery/src/jquery",
    },
  },
};

module.exports = merge(webpackConfig, aliasConfig);
