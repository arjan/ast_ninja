import React, { useReducer } from 'react'
import AppUI from './AppUI'
import { channel } from '../socket'

function reducer(state, { action, payload }) {
  if (action === 'parse') {
    const { code, parsers } = state

    channel.push('parse', { code, parsers }).receive('ok', payload => {
      global.dispatch({ action: 'parseResult', payload })
    })
  }

  else if (action) {
    // simple save action
    return { ...state, [action]: payload }
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
