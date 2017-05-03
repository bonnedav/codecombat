api = require 'core/api'
module.exports = ShareLicensesStoreModule = {
  namespaced: true
  state: {
    _prepaid: { joiners: [] }
  }
  mutations: {
    setPrepaid: (state, prepaid) ->
      state._prepaid = prepaid
    addTeacher: (state, userID) ->
      state._prepaid.joiners.push({userID})
  }
  actions: {
    setPrepaid: ({ commit }, prepaid) ->
      userRequests = prepaid.joiners.map (joiner) ->
        console.log "Requesting user for", joiner.userID
        api.users.getByHandle(joiner.userID).then (user) ->
          _.assign(joiner, _.pick(user, 'name', 'email'))
          # TODO: Make sure endpoint includes the email for this case
          console.log "Got requested user:", user
      Promise.all(userRequests).then ->
        console.log prepaid
        # TODO: Only add 'me' if I've used any?
        prepaid.joiners.push({
          userID: me.id
          name: me.get('name')
          email: me.get('email')
        })
        commit('setPrepaid', prepaid)
    addTeacher: ({ commit }, email) ->
      # TODO: Use API for this instead
      $.get('/db/user', { email }).then (user) =>
        commit('addTeacher', user.id)
      null
  }
  getters: {
    prepaid: (state) ->
      _.assign({}, state._prepaid, {
        joiners: state._prepaid.joiners.map (joiner) ->
          _.assign {}, joiner,
            licensesUsed: _.countBy(state._prepaid.redeemers, (redeemer) ->
              (not redeemer.teacherID and joiner.userID is me.id) or (redeemer.teacherID is joiner.userID)
            )[true] or 0
      })
  }
}

module.exports = ShareLicensesStoreModule
