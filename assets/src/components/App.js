import React, { useReducer } from 'react'
import AppUI from './AppUI'

function reducer(state, { action, payload }) {
  if (action) {
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

export default function() {
  const [state, dispatch] = useReducer(reducer, INITIAL_STATE)
  return (
    <AppUI state={state} dispatch={dispatch} />
  )
}
