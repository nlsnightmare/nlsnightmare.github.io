module.exports = {
  future: {
    removeDeprecatedGapUtilities: true,
    purgeLayersByDefault: true,
  },
  purge: {
    mode: 'all',
    content: [
      './*.html',
      './*.md',
      './_*/**/*.md',
      './_*/**/*.html',
    ]
  },
  theme: {
    extend: {},
  },
  variants: {},
  plugins: [],
}
