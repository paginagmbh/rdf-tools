miss = require "mississippi"

inverseOf = "http://www.w3.org/2002/07/owl#inverseOf"

module.exports =
    model: (cb) ->
        inversed = {}

        transform = (triple, _, next) ->
            {subject, predicate, object} = triple
            if predicate.value is inverseOf
                mapping = inversed[object.value] ?= {}
                mapping[subject.value] = true
            next null, triple

        flush = (next) ->
            cb { inversed }
            next()

        miss.through.obj transform, flush