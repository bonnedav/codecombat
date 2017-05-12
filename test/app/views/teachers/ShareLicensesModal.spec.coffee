ShareLicensesModal = require 'views/teachers/ShareLicensesModal'
factories = require '../../factories'
api = require 'core/api'

describe 'ShareLicensesModal', ->
  afterEach ->
    @modal?.destroy?() unless @modal?.destroyed
  
  describe 'joiner list', ->
    beforeEach (done) ->
      window.me = @teacher = factories.makeUser({firstName: 'teacher', lastName: 'one'})
      @joiner1 = factories.makeUser({firstName: 'joiner', lastName: 'one'})
      @joiner2 = factories.makeUser({firstName: 'joiner', lastName: 'two'})
      @prepaid = factories.makePrepaid({ joiners: [{ userID: @joiner1.id }, { userID: @joiner2.id }] })
      spyOn(api.prepaids, 'fetchJoiners').and.returnValue Promise.resolve([
          _.pick(@joiner1.attributes, '_id', 'name', 'email', 'firstName', 'lastName')
          _.pick(@joiner2.attributes, '_id', 'name', 'email', 'firstName', 'lastName')
        ])
      @modal = new ShareLicensesModal({ prepaid: @prepaid.attributes })
      @modal.render()
      @store = @modal.shareLicensesComponent.$store
      _.defer ->
        done()
    
    it 'shows a list of joiners', ->
      expect(@modal.$el.html()).toContain('joiner one')
      expect(@modal.$el.html()).toContain(@joiner1.get('email'))
      expect(@modal.$el.html()).toContain('joiner two')
      expect(@modal.$el.html()).toContain(@joiner2.get('email'))
      
    describe 'Add Teacher button', ->
      beforeEach (done) ->
        @joiner3 = factories.makeUser({firstName: 'joiner', lastName: 'three'})
        spyOn(api.prepaids, 'addJoiner').and.returnValue Promise.resolve(@prepaid.toJSON())
        console.log _.pick(@joiner3.toJSON(), '_id', 'name', 'email', 'firstName', 'lastName')
        spyOn(api.users, 'getByEmail').and.returnValue Promise.resolve(_.pick(@joiner3.toJSON(), ['_id', 'name', 'email', 'firstName', 'lastName']))
        _.defer ->
          done()
        
      it 'can add a joiner', (done) ->
        @modal.shareLicensesComponent.teacherSearchInput = @joiner3.get('email')
        @modal.shareLicensesComponent.addTeacher().then =>
          joiners = @modal.shareLicensesComponent.prepaid.joiners
          expect(joiners[0].firstName).toBe('joiner')
          expect(joiners[0].lastName).toBe('three')
          expect(joiners[0].email).toBe(@joiner3.get('email'))
          done()
