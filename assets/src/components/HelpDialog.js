import React from 'react'
import { Dialog } from '@blueprintjs/core'

export default class extends React.Component {
  render() {
    const { dispatch } = this.props

    return (
      <Dialog title="What is this?" isOpen onClose={() => dispatch({ action: 'help', payload: false })}>
        <div className="bp3-dialog-body">

          The <b>AST Ninja</b> is a tool that I built for the presentation "The Elixir Parser under the Microscope" that was presented on the ElixirConf EU 2019 in Prague.

        </div>
      </Dialog>
    )
  }
}
