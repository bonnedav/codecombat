ModalView = require 'views/core/ModalView'
State = require 'models/State'
TrialRequests = require 'collections/TrialRequests'
forms = require 'core/forms'
store = require('core/store')

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
  storeModule: require('./ShareLicensesStoreModule')
  created: ->
  data: ->
    me: me
    teacherSearchInput: ''
    prepaid:
      joiners: [
        {name: 'phoenix', email: 'phoenix+teacher3@codecombat.com', licensesUsed: 1}
        {name: 'someone else', email: 'phoenix+teacher5a@codecombat.com', licensesUsed: 2}
      ]
  computed: {}
  components:
    'share-licenses-joiner-row': require('./ShareLicensesJoinerRow')
  methods:
    findTeacher: ->
      console.log 'finding teacher!', @teacherSearchInput
