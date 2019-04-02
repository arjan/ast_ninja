import React, { useState } from 'react'
import classNames from 'classnames'
import Ansi from 'ansi-to-react'
import { Callout, Tag, Checkbox } from '@blueprintjs/core'

function renderMetadata({ metadata }) {
  return (
    <div className="metadata">
      {Object.keys(metadata).map(k => <Tag intent="primary" key={k}>{k}: {metadata[k]}</Tag>)}
    </div>
  )
}

function renderWarnings({ warnings }) {
  return (
    <Callout intent="warning">
      <ul>
        {warnings.map(({ message }, idx) => <li key={idx}>{message}</li>)}
      </ul>
    </Callout>
  )
}

function renderParserOpts(opts, state, name, dispatch) {
  return (
    <Callout>
      {opts.map(([ label, opt ]) =>
        <Checkbox
          key={opt}
          inline
          checked={!!state[opt]}
          label={label}
          onChange={e => dispatch({ action: 'parserOpt', payload: { name, opt, checked: e.target.checked }})}
        />)
      }
    </Callout>
  )
}

let prev = {}

export default function({ state, dispatch, name, opts }) {
  const output = state.parseResult[name] || {}
  const { code, error, warnings, metadata } = output

  if (!error) prev[name] = code
  return (
    <div className={classNames('raw-output', { error })}>
      {error && <div className="error">{error}</div>}
      {warnings && warnings.length && renderWarnings(output) || null}
      <div className="main">
        <Ansi>{code || prev[name]}</Ansi>
        {metadata && renderMetadata(output)}
      </div>
      {opts && renderParserOpts(opts, state.parserOpts[name] || {}, name, dispatch)}
    </div>
  )
}
