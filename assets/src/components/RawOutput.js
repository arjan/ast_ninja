import React from 'react'
import Ansi from 'ansi-to-react'
import { Callout, Tag } from '@blueprintjs/core'

export default class extends React.Component {
  render() {
    const { name } = this.props
    const output = this.props.state.parseResult[name] || {}

    return (
      <div className="raw-output">
        {output.error && <div className="error">{output.error}</div>}
        <Ansi>{output.code}</Ansi>
        {output.metadata ?
        <Callout>
          {Object.keys(output.metadata).map(k => <Tag large intent="primary" bkey={k}>{k}: {output.metadata[k]}</Tag>)}
        </Callout>
        : null}
      </div>
          )
  }
}
