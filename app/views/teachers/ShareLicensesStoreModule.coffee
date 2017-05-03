api = require 'core/api'
module.exports = ShareLicensesStoreModule = {
  namespaced: true
  state: {
    _prepaid: { joiners: [] }
  }
  mutations: {
    setPrepaid: (state, prepaid) ->
      state._prepaid = prepaid
    addTeacher: (state, user) ->
      state._prepaid.joiners.push({
        userID: user.id
        name: user.name
        email: user.email
      })
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
    addTeacher: ({ commit, state }, email) ->
      # TODO: Use API for this instead
      # TODO: Update the prepaid in the DB
      $.get('/db/user', { email }).then (user) =>
        $.post("/db/prepaid/#{state._prepaid._id}/joiners", {userID: user._id}).then =>
          console.log "Added user to prepaid"
          commit('addTeacher', user)
        , (e) ->
          console.log e
      , (e) ->
        commit('setError', 'userNotFound')
        console.log e
      # TODO: Error handling?
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
