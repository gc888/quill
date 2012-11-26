ALPHABET = "abcdefghijklmnopqrstuvwxyz\n\n\n\n\n\t\t\t   ".split('')
ATTRIBUTES = _.extend({}, Tandem.Constants.SPAN_ATTRIBUTES, Tandem.Constants.TAG_ATTRIBUTES)
NUM_OPERATIONS = 500

seed = Math.random()
console.info seed
Math.seedrandom(seed.toString())


$(document).ready( ->
  rangy.init()
  $editors = $('.editor-container')
  writer = new Tandem.Editor($editors.get(0))
  reader = new Tandem.Editor($editors.get(1))
  start = new Date()

  writer.on(Tandem.Editor.events.TEXT_CHANGE, (delta) ->
    reader.applyDelta(delta)
  )

  operationsLeft = NUM_OPERATIONS
  async.whilst( ->
    return operationsLeft > 0
  , (callback) ->
    operationsLeft -= 1
    _.defer( ->
      writerHTML = writer.doc.root.innerHTML
      readerHTML = reader.doc.root.innerHTML
      operation = Tandem.Debug.Test.getRandomOperation(writer, ALPHABET, ATTRIBUTES)
      if operation?
        try
          writer[operation.op].apply(writer, operation.args)
        catch e
          console.error operation
          console.error writerHTML
          console.error readerHTML
          callback(e)
          return
        writerDelta = writer.doc.toDelta()
        readerDelta = reader.doc.toDelta()
        if _.isEqual(writerDelta, readerDelta)
          callback(null)
        else
          console.error operation
          console.error writerHTML
          console.error readerHTML
          console.error 'writer', writerDelta
          console.error 'reader', readerDelta
          callback("Editor diversion after #{NUM_OPERATIONS - operationsLeft} operations")
      else
        callback(null)
    )
  , (err) ->
    if err?
      console.error err
      console.error err.message if err.message?
      console.error err.stack if err.stack?
    else
      writerDelta = writer.getDelta()
      readerDelta = reader.getDelta()
      if _.isEqual(writerDelta, readerDelta)
        time = (new Date() - start) / 1000
        console.info "Fuzzing passed"
        console.info time, 'seconds'
        console.info (NUM_OPERATIONS / time).toPrecision(2), 'ops/sec'
      else
        console.error "Fuzzing failed", writer, reader
  )
)
