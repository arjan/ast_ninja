import React from 'react'
import Ansi from 'ansi-to-react'
import { Callout, Tag } from '@blueprintjs/core'

export default class extends React.Component {

  renderMetadata({ metadata }) {
    return (
      <Callout>
        {Object.keys(metadata).map(k => <Tag large intent="primary" key={k}>{k}: {metadata[k]}</Tag>)}
      </Callout>
    )
  }

  renderWarnings({ warnings }) {
    return (
      <Callout intent="warning">
        <ul>
          {warnings.map(({ message }, idx) => <li key={idx}>{message}</li>)}
        </ul>
      </Callout>
    )
  }

  render() {
    const { name } = this.props
    const output = this.props.state.parseResult[name] || {}

    return (
      <div className="raw-output">
        {output.error && <div className="error">{output.error}</div>}
        {output.warnings && output.warnings.length && this.renderWarnings(output) || null}
        <Ansi>{output.code}</Ansi>
        {output.metadata && this.renderMetadata(output)}
      </div>
    )
  }
}
