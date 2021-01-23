const { process } = require('autoprefixer');

module.exports = {
  purge: {
    content: ['web/doc/index.htm', 'web/doc/index.js'],
  },
  darkMode: false, // or 'media' or 'class'
  theme: {
    extend: {},
  },
  variants: {
    extend: {},
  },
  plugins: [],
};
