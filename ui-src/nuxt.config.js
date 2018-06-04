var isDev = require('./plugins/is-dev');

module.exports = {
  plugins : [    
    '~/node_modules/clean-ui/clean-ui.nuxt'    
  ],
  router: {
    base: (isDev ? '/' : './'), 
    mode : 'hash'
  },
  
  /* MODULES */
  modules: [
    
  ],
  /*
  ** Headers of the page
  */
  generate: {
    minify: {
      removeComments: true,      
    },
  },
  head: {
    title: 'ui-src',
    meta: [
      { charset: 'utf-8' },
      { name: 'viewport', content: 'width=device-width, initial-scale=1' },
      { hid: 'description', name: 'description', content: 'SketchUp Groundhog UI' },
      //<meta http-equiv="X-UA-Compatible" content="IE=edge"/>
      // This is for Windows
      { "http-equiv" : 'X-UA-Compatible', content : 'IE=edge' }
      
    ],
    link: [
      { rel: 'icon', type: 'image/x-icon', href: '/favicon.ico' }
    ]
  },
  /*
  ** Customize the progress bar color
  */
  loading: false,
  /*
  ** Build configuration
  */
  build: {
    plugins:[
    ],
    /*
    ** Run ESLint on save
    */
    extend (config, { isDev, isClient }) {
      if (isDev && isClient) {
        config.module.rules.push({
          enforce: 'pre',
          test: /\.(js|vue)$/,
          loader: 'eslint-loader',
          exclude: /(node_modules)/
        })
      }
    }
  }
}
