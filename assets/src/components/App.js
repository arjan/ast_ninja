import React, { useReducer } from 'react'
import AppUI from './AppUI'
import { channel } from '../socket'
import { LAYOUTS, prevLayout, nextLayout } from '../layouts'

export function getEnabledPanels(mosaic) {
  const rendered = []
  if (typeof mosaic === 'string') {
    rendered.push(mosaic)
  } else {
    const traverse = ({ first, second }) => {
      if (typeof first === 'string') {
        rendered.push(first)
      } else {
        traverse(first)
      }
      if (typeof second === 'string') {
        rendered.push(second)
      } else {
        traverse(second)
      }
    }
    traverse(mosaic, rendered)
  }
  return rendered
}

function runParsers({ code, formatter, code_is_ast, mosaic, parserOpts }) {
  const parsers = getEnabledPanels(mosaic).filter(p => p !== 'elixir')
  channel.push('parse', { code, formatter, code_is_ast, parsers, options: parserOpts }).receive('ok', payload => {
    global.dispatch({ action: 'parseResult', payload })
    if (payload.formatted) {
      global.dispatch({ action: 'code', payload: payload.formatted, force: code !== payload.formatted })
    }
  })
}

function reducer(state, { action, payload, force }) {
  if (action === 'parse') {
    runParsers(state)

  } else if (action === 'parserOpt') {
    const { name, opt, value, checked } = payload
    state = { ...state, parserOpts: { ...state.parserOpts, [name]: { ...state.parserOpts[name], [opt]: value || checked } } }
    runParsers(state)

  } else if (action === 'layoutNext') {
    state = { ...state, mosaic: nextLayout() }
    runParsers(state)

  } else if (action === 'layoutPrev') {
    state = { ...state, mosaic: prevLayout() }
    runParsers(state)

  } else if (action) {
    // simple save action
    state = { ...state, [action]: payload }
    if (action === 'formatter' || action === 'code_is_ast' || force) {
      runParsers(state)
    }
  }
  return state
}

const INITIAL_STATE = {
  code: '',
  formatter: false,
  code_is_ast: false,
  parseResult: {},
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
