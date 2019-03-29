import React, { useReducer } from 'react'
import AppUI from './AppUI'
import { channel } from '../socket'

function runParsers({ code, formatter, parsers }) {
  channel.push('parse', { code, formatter, parsers }).receive('ok', payload => {
    global.dispatch({ action: 'parseResult', payload })
    if (payload.formatted) {
      global.dispatch({ action: 'code', payload: payload.formatted })
    }
  })
}

function reducer(state, { action, payload }) {
  if (action === 'parse') {
    runParsers(state)
  }

  else if (action) {
    // simple save action
    state = { ...state, [action]: payload }
    if (action === 'formatter') {
      runParsers(state)
    }
  }
  return state
}

const CODE = `# this is a demo
defmodule Greeting do
  def hello do
    IO.puts "Hello, world!"
  end
end
`

const INITIAL_STATE = {
  code: CODE,
  formatter: false,
  parseResult: {},
  parsers: null
}

const global = {
  dispatch: null
}

export default function() {
  const [state, dispatch] = useReducer(reducer, INITIAL_STATE)
  global.dispatch = dispatch
  return (
    <AppUI state={state} dispatch={dispatch} />
  )
}
