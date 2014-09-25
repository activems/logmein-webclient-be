nock = require 'nock'
chai = require 'chai'


assert = chai.assert
expect = chai.expect

TokenValidator = require('../lib/token_validator.js')


MOCK_SERVER = 'http://api.mock.com'

validator = undefined
mockServer = undefined

describe 'TokenValidator', ->
    
    before () ->
        #Setup the mock server
        mockServer = nock(MOCK_SERVER)

    beforeEach () ->
        validator = new TokenValidator({ host: MOCK_SERVER, apiVersion: "v1" })

    it 'should return a correct resource path for the provided config', ->
        validatorv5 = new TokenValidator({apiVersion: "v5"})
        path = validatorv5._getResourcePath("validatetoken")
        expect(path).to.be.equal "/v5/oauth2/validatetoken"

    it 'should trigger the smoke test', ->

    it 'should use the mock server' , ->
        host = validator.getHost()
        expect(host).to.be.equal MOCK_SERVER

     it 'should trigger the smoke test', (done) ->
        mockServer.get("/").reply(200, "")
        done() 

    it 'should trigger callback on valid token response', (done) ->
        mockServer.get(
                validator._getResourcePath('validatetoken'), 
                { access_token: "TOKEN_ID" }
                )
            .reply(2300, "") 

        validator.validateToken("TOKEN_ID",
            (request) =>
                #Just return a success code to the client
                expect(request.responseCode).to.be.equal 200
                done()
            ,
            (request) =>
                assert.ok(false, "This shoudl not happen")
                done()
            ,
            (e) =>
                assert.ok(false, e)
                done()
        )
      

