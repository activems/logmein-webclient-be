nock = require 'nock'
chai = require 'chai'


assert = chai.assert
expect = chai.expect

LogmeinWebClientBe = require('../lib/main.js')


MOCK_SERVER = 'http://api.mock.com'

validator = undefined
mockServer = undefined

describe 'LogmeinWebClientBe', ->
    
    it 'has defaults for default constructor', ->
        validator = LogmeinWebClientBe() 
        expect(validator.getHost()).to.be.equal(validator.DEFAULT_HOST)
        expect(validator.getPort()).to.be.equal(validator.DEFAULT_PORT)
        expect(validator.getApiVersion()).to.be.equal(validator.DEFAULT_API)

    it 'has defaults for undefined fields', ->
        validator = LogmeinWebClientBe({ host: "test.com", apiVersion: "v2"}) 
        expect(validator.getHost()).to.be.equal("test.com")
        expect(validator.getPort()).to.be.equal(validator.DEFAULT_PORT)
        expect(validator.getApiVersion()).to.be.equal("v2")

    it 'validates token agains server', (done) ->
        validator = LogmeinWebClientBe()
        validator.validateToken("Jg5UFfwqvNNsMr4DwB5KyvS5JIEq1A",
            (request)->
                console.log("TOKEN is valid")
                done()
            ,
            (request)->
                console.log("TOKEN is not valid")
                done()
            ,
            (e)->
                console.log("ERROR " + e)
                done()
                )

    it 'obtains resources from the server', (done) ->
        validator = LogmeinWebClientBe()
        validator.getResource("Jg5UFfwqvNNsMr4DwB5KyvS5JIEq1A", "/profile", undefined
            (response)->
                response.on 'data', (data) =>
                    console.log("TOKEN is valid " + data)
                    done()
            ,
            (e)->
                console.log("ERROR " + e)
                done()
                )