import React, { useReducer } from 'react'
import AppUI from './AppUI'
import { channel } from '../socket'
import { Hotkey, Hotkeys, HotkeysTarget } from "@blueprintjs/core";

function runParsers({ code, formatter, parsers, parserOpts }) {
  channel.push('parse', { code, formatter, parsers, options: parserOpts }).receive('ok', payload => {
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
  if (action === 'parserOpt') {
    const { name, opt, checked } = payload
    state = { ...state, parserOpts: { ...state.parserOpts, [name]: { ...state.parserOpts[name], [opt]: checked } } }
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
  parsers: null,
  parserOpts: {},
  optIndex: 0,
}

const global = {
  dispatch: null
}

@HotkeysTarget
class MyHotkeys extends React.Component {
  renderHotkeys() {
    const { state, dispatch } = this.props

    return <Hotkeys>
      <Hotkey
        global={true}
        combo="mod + i"
        label="Increase the option index"
        onKeyDown={() => dispatch({ action: 'optIndex', payload: (state.optIndex + 1) % 4 })}
      />
    </Hotkeys>;
  }

  render() {
    return this.props.children
  }
}

export default function() {
  const [state, dispatch] = useReducer(reducer, INITIAL_STATE)
  global.dispatch = dispatch

  return (
    <MyHotkeys state={state} dispatch={dispatch}>
      <AppUI state={state} dispatch={dispatch} />
    </MyHotkeys>
  )
}
