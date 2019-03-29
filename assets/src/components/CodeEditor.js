import React from 'react'
import AceEditor from 'react-ace'
import throttle from 'lodash/throttle'
import debounce from 'lodash/debounce'
import 'brace/mode/elixir'
import 'brace/theme/textmate'
import { Navbar, Checkbox } from '@blueprintjs/core'

export default class extends React.Component {

  updateImmediate = throttle(() => {
    this.props.dispatch({ action: 'parse' })
  }, 100)

  updateDelayed = debounce(() => {
    this.props.dispatch({ action: 'parse' })
  }, 800)

  onCodeChange = (payload) => {
    this.props.dispatch({ action: 'code', payload })
    if (this.props.state.formatter) {
      this.updateDelayed()
    } else {
      this.updateImmediate()
    }
  }

  render() {
    const { state, dispatch } = this.props

    return (
      <div className="code-editor">
        <AceEditor
          mode="elixir"
          theme="textmate"
          value={state.code}
          onChange={this.onCodeChange}
          name="editor"
          tabSize={2}
          useSoftTabs
          editorProps={{ $blockScrolling: Infinity }}
        />
        <Navbar>
          <Navbar.Group align="right">
            <Checkbox checked={state.formatter} onChange={e => dispatch({ action: 'formatter', payload: e.target.checked })} label="Auto-format" />
          </Navbar.Group>
        </Navbar>
      </div>
    )
  }
}
