import React, { useState } from 'react'
import classNames from 'classnames'
import Ansi from 'ansi-to-react'
import { Callout, Tag, Checkbox, RadioGroup, Radio } from '@blueprintjs/core'

import AceEditor from 'react-ace'
import 'brace/mode/elixir'
import 'brace/theme/textmate'

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

function renderRadios(label, opt, state, name, dispatch) {
  return (
    <RadioGroup
      key={label}
      inline
      onChange={e => dispatch({ action: 'parserOpt', payload: { name, opt: label, value: e.target.value }})}
      selectedValue={state[label] || opt[0]}
    >
      {opt.map((o, i) => <Radio key={i} label={o} value={o} />)}
    </RadioGroup>
  )
}

function renderParserOpts(opts, state, name, dispatch) {
  return (
    <Callout>
      {opts.map(([ label, opt ]) =>
        typeof opt === 'string'
        ? <Checkbox
            key={opt}
            inline
            checked={!!state[opt]}
            label={label}
            onChange={e => dispatch({ action: 'parserOpt', payload: { name, opt, checked: e.target.checked }})}
        /> : renderRadios(label, opt, state, name, dispatch))
      }
    </Callout>
  )
}

let prev = {}

function renderEditor(code) {
  return (
    <div className="code-editor">
      <AceEditor
        readOnly
        wrapEnabled
        highlightActiveLine={false}
        showGutter={false}
        mode="elixir"
        theme="textmate"
        value={code}
        name="editor"
        tabSize={2}
        useSoftTabs
        editorProps={{ $blockScrolling: Infinity }}
      />
    </div>
  )
}

export default function({ state, dispatch, name, isElixir, opts }) {
  const output = state.parseResult[name] || {}
  const { code, error, warnings, metadata, equal } = output
  const { showOptions } = state

  if (!error) prev[name] = code
  return (
    <div className={classNames('raw-output', { error })}>
      {equal && !state.code_is_ast ? <Callout icon="tick" intent="success">Output equal to input</Callout> : null}
      {error && <div className="error">{error}</div>}
      {warnings && warnings.length && renderWarnings(output) || null}
      <div className="main">
        {isElixir ? renderEditor(code || prev[name]) : <Ansi>{code || prev[name]}</Ansi>}
        {showOptions && metadata && renderMetadata(output)}
      </div>
      {showOptions && opts && opts.length > 0 && renderParserOpts(opts, state.parserOpts[name] || {}, name, dispatch)}
    </div>
  )
}
