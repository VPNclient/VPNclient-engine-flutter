const { getDefaultConfig } = require("metro-config");

/**
 * Metro configuration
 * https://facebook.github.io/metro/docs/configuration
 */

module.exports = (async () => {
  const config = await getDefaultConfig(__dirname);
  return config;
})();