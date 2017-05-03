store = require('core/store')
ShareLicensesStoreModule = require './ShareLicensesStoreModule'

module.exports = ShareLicensesJoinerRow =
  name: 'share-licenses-joiner-row'
  template: require('templates/teachers/share-licenses-joiner-row')()
  storeModule: ShareLicensesStoreModule
  props:
    joiner:
      type: Object
      default: -> {name: 'phoenix', email: 'phoenix+teacher3@codecombat.com'}
    prepaid:
      type: Object
      default: ->
        joiners: []
  created: ->
  data: ->
    me: me
  computed: {}
  components: {}
  methods:
    {}
