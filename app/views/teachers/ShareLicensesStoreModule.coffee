api = require 'core/api'

initialState = {
  _prepaid: { joiners: [] }
  error: ''
}

translateError = (message) ->
  if /You've already shared these licenses with that teacher/.test(message)
    return i18n.t('share_licenses.already_shared')
  else if /No user with that email/.test(message)
    return i18n.t('share_licenses.teacher_not_found')
  else if /Teacher Accounts can only look up other Teacher Accounts/.test(message)
    return i18n.t('share_licenses.teacher_not_valid')
  else
    return message

module.exports = ShareLicensesStoreModule =
  namespaced: true
  state: _.cloneDeep(initialState)
  mutations:
    # NOTE: Ideally, this store should fetch the prepaid, but we're already handed it by the Backbone parent
    setPrepaid: (state, prepaid) ->
      state._prepaid = prepaid
    addTeacher: (state, user) ->
      state._prepaid.joiners.push({
        userID: user._id
        name: user.name
        email: user.email
      })
    setError: (state, error) ->
      state.error = error
    clearData: (state) ->
      _.assign state, initialState
  actions:
    setPrepaid: ({ commit }, prepaid) ->
      prepaid = _.cloneDeep(prepaid)
      prepaid.joiners ?= []
      userRequests = prepaid.joiners.map (joiner) ->
        console.log "Requesting user for", joiner.userID
        api.users.getByHandle(joiner.userID).then (user) ->
          _.assign(joiner, _.pick(user, 'name', 'firstName', 'lastName', 'email'))
      Promise.all(userRequests).then ->
        prepaid.joiners.push(_.assign({ userID: me.id }, me.pick('name', 'firstName', 'lastName', 'email')))
        commit('setPrepaid', prepaid)
    addTeacher: ({ commit, state }, email) ->
      # TODO: Use API for this instead
      api.users.getByEmail(email).then (user) =>
        console.log "Got a user:", user
        api.prepaids.addJoiner({prepaidID: state._prepaid._id, userID: user._id}).then =>
          console.log "Added a joiner!"
          commit('addTeacher', user)
      .catch (error) =>
        console.log error
        commit('setError', translateError(error.responseJSON?.message or error.message or error))
      null
  getters:
    prepaid: (state) ->
      _.assign({}, state._prepaid, {
        joiners: state._prepaid.joiners.map (joiner) ->
          _.assign {}, joiner,
            licensesUsed: _.countBy(state._prepaid.redeemers, (redeemer) ->
              (not redeemer.teacherID and joiner.userID is me.id) or (redeemer.teacherID is joiner.userID)
            )[true] or 0
      })
    error: (state) -> state.error
