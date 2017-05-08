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
      $.get('/db/user', { email }).then (user) =>
        $.post("/db/prepaid/#{state._prepaid._id}/joiners", {userID: user._id}).then =>
          commit('addTeacher', user)
        , (e) ->
          commit('setError', translateError(e.responseJSON?.message))
      , (e) ->
        commit('setError', translateError(e.responseJSON?.message))
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
