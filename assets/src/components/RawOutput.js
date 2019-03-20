import React from 'react'
import Ansi from 'ansi-to-react'

export default class extends React.Component {
  render() {
    const { name } = this.props
    const output = this.props.state.parseResult[name] || {}

    return (
      <div className="raw-output">
        {output.error && <div className="error">{output.error}</div>}
        <Ansi>{output.code}</Ansi>
      </div>
    )
  }
}
