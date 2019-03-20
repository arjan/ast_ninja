import React from 'react'
import Ansi from 'ansi-to-react'

export default class extends React.Component {
  render() {
    console.log(this.props)

    const { name } = this.props
    const output = this.props.state.parseResult[name] || ""

    return (
      <div className="raw-output">
        <Ansi>{output}</Ansi>
      </div>
    )
  }
}
