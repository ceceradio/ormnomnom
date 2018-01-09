'use strict'

const {beforeEach, afterEach, teardown, test} = require('tap')

const ormnomnom = require('..')
const db = require('./db')

db.setup(beforeEach, afterEach, teardown)

test('produces expected table name', assert => {
  class TestFoo {
  }
  const objects = ormnomnom(TestFoo, {
    id: ormnomnom.joi.number()
  })
  return objects.all().sql.then(sql => {
    assert.ok(/"test_foos"/g.test(sql))
  })
})

test('throws if passed to two ormnomnoms', assert => {
  class TestFoo {
  }
  ormnomnom(TestFoo, {
    id: ormnomnom.joi.number()
  })

  assert.throws(() => {
    ormnomnom(TestFoo)
  })

  assert.end()
})
