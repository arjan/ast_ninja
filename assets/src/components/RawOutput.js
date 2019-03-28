import React, { useState } from 'react'
import classNames from 'classnames'
import Ansi from 'ansi-to-react'
import { Callout, Tag } from '@blueprintjs/core'

function renderMetadata({ metadata }) {
  return (
    <Callout>
      {Object.keys(metadata).map(k => <Tag large intent="primary" key={k}>{k}: {metadata[k]}</Tag>)}
    </Callout>
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

let prev = {}

export default function({ state, name }) {
  const output = state.parseResult[name] || {}
  const { code, error, warnings, metadata} = output

  if (!error) prev[name] = code
  return (
    <div className={classNames('raw-output', { error })}>
      {error && <div className="error">{error}</div>}
      {warnings && warnings.length && this.renderWarnings(output) || null}
      <Ansi>{code || prev[name]}</Ansi>
      {metadata && this.renderMetadata(output)}
    </div>
  )
}
