ModalView = require 'views/core/ModalView'
State = require 'models/State'
TrialRequests = require 'collections/TrialRequests'
forms = require 'core/forms'
store = require('core/store')
ShareLicensesStoreModule = require './ShareLicensesStoreModule'

module.exports = class ShareLicensesModal extends ModalView
  id: 'share-licenses-modal'
  template: require 'templates/teachers/share-licenses-modal'
  events: {}
  initialize: (options={}) ->
    @shareLicensesComponent = null
  afterRender: ->
    target = @$el.find('#share-licenses-component')
    if @shareLicensesComponent
      target.replaceWith(@shareLicensesComponent.$el)
    else
      @shareLicensesComponent = new ShareLicensesComponent({
        el: target[0]
        store
      })

ShareLicensesComponent = Vue.extend
  name: 'share-licenses-component'
  template: require('templates/teachers/share-licenses-component')()
  storeModule: ShareLicensesStoreModule
  created: ->
  data: -> {}
  computed: {}
  components: {}
  methods: {}
