const colors = require('tailwindcss/colors')

module.exports = {
  purge: {
    mode: 'all',
    content: [
      './_site/*/**/*.html',
    ]
  },
  darkMode: false, // or 'media' or 'class'
  theme: {
    colors: {
      ...colors
    },
    extend: {
      screens: {
        'xs': '450px',
      }
    },
  },
  variants: {
    extend: {},
  },
  plugins: [],
}
