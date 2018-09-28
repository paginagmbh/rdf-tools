N3 = require "n3"
miss = require "mississippi"

debug = require "debug"
log = debug "rdf-tools"

gnd = require "../lib/gnd"
iconclass = require "../lib/iconclass"
getty = require "../lib/getty"
crm = require "../lib/cidoc-crm"
owl = require "../lib/owl"

head = (limit=10, done) ->
    miss.to.obj (obj, enc, cb) ->
        if limit-- is 0
            done() if done?
            this.destroy()
        else
            log obj
            cb()

once = (fn) ->
    called = false
    () ->
        if not called
            called = true
            fn.apply null, arguments

describe "GND", ->
    it "can be retrieved", (done) ->
        done = once done
        miss.pipe gnd.stream(done), gnd.parsed(), head(3, done), done

describe "ICONCLASS", ->
    it "can be retrieved", (done) ->
        done = once done
        miss.pipe iconclass.stream(done), iconclass.parsed(), head(3, done), done

describe "Getty/AAT", ->
    it "can be retrieved", (done) ->
        done = once done

        to = miss.pipeline.obj getty.parsed(), head(3, done)
        miss.finished(to, done)

        getty.aat to, getty.hierarchy

describe "CIDOC/CRM", ->
    it "can be retrieved", (done) ->
        done = once done

        miss.pipe crm.stream(), crm.parsed(), owl.model(log),
            head(-1, done), done
