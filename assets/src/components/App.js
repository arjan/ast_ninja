import React, { useReducer } from 'react'
import AppUI from './AppUI'
import { channel } from '../socket'
import { LAYOUTS } from '../layouts'

function runParsers({ code, formatter, parsers, parserOpts }) {
  channel.push('parse', { code, formatter, parsers, options: parserOpts }).receive('ok', payload => {
    global.dispatch({ action: 'parseResult', payload })
    if (payload.formatted) {
      global.dispatch({ action: 'code', payload: payload.formatted, force: code !== payload.formatted })
    }
  })
}

function reducer(state, { action, payload, force }) {
  if (action === 'parse') {
    runParsers(state)
  }
  if (action === 'parserOpt') {
    const { name, opt, value, checked } = payload
    state = { ...state, parserOpts: { ...state.parserOpts, [name]: { ...state.parserOpts[name], [opt]: value || checked } } }
    runParsers(state)
  }

  else if (action) {
    // simple save action
    state = { ...state, [action]: payload }
    if (action === 'formatter' || force) {
      runParsers(state)
    }
  }
  return state
}

const INITIAL_STATE = {
  code: '',
  formatter: false,
  parseResult: {},
  parsers: null,
  parserOpts: {},
  mosaic: LAYOUTS[0],
  showOptions: false,
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
