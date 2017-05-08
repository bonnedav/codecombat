ModalView = require 'views/core/ModalView'
State = require 'models/State'
TrialRequests = require 'collections/TrialRequests'
forms = require 'core/forms'
store = require('core/store')
ShareLicensesStoreModule = require('./ShareLicensesStoreModule')

module.exports = class ShareLicensesModal extends ModalView
  id: 'share-licenses-modal'
  template: require 'templates/teachers/share-licenses-modal'
  events: {}
  initialize: (options={}) ->
    @shareLicensesComponent = null
    store.registerModule('shareLicenses', ShareLicensesStoreModule) #TODO: Do I use this or 'modal' namespace?
    store.dispatch('shareLicenses/setPrepaid', options.prepaid)
  afterRender: ->
    target = @$el.find('#share-licenses-component')
    if @shareLicensesComponent
      target.replaceWith(@shareLicensesComponent.$el)
    else
      @shareLicensesComponent = new ShareLicensesComponent({
        el: target[0]
        store
      })
  destroy: ->
    console.log "destroy"
    @shareLicensesComponent.$destroy()
    super(arguments...)

ShareLicensesComponent = Vue.extend
  name: 'share-licenses-component'
  template: require('templates/teachers/share-licenses-component')()
  storeModule: ShareLicensesStoreModule
  data: ->
    me: me
    teacherSearchInput: ''
  computed: _.assign({}, Vuex.mapGetters(prepaid: 'shareLicenses/prepaid', error: 'shareLicenses/error'))
  watch:
    teacherSearchInput: ->
      @$store.commit('shareLicenses/setError', '')
  components:
    'share-licenses-joiner-row': require('./ShareLicensesJoinerRow')
  methods:
    addTeacher: ->
      @$store.dispatch('shareLicenses/addTeacher', @teacherSearchInput)
  created: ->
  destroyed: ->
    console.log "destroyed"
    @$store.commit('shareLicenses/clearData')
    @$store.unregisterModule('shareLicenses')
