import React from 'react'
import debounce from 'lodash/debounce'
import Ansi from 'ansi-to-react'
import { channel } from 'socket'
import AceEditor from 'react-ace'

import 'brace/mode/elixir'
import 'brace/theme/github'

export default class Component extends React.Component {
  state = {
    code: '',
    pretty: ''
  }

  update = debounce(() => {
    const { code } = this.state
    channel.push('parse', { code }).receive('ok', ({ pretty }) => {
      console.log('pretty', pretty)

      this.setState({ pretty })
    })
  }, 400)

  onCodeChange = (code) => {
    this.setState({ code })
    this.update()
  }

  render() {
    const { code, pretty } = this.state
    return (
      <div className="explorer--wrapper">
        <div className="panel">
          <h5>Code</h5>
          <AceEditor
            mode="elixir"
            theme="github"
            value={code}
            onChange={this.onCodeChange}
            name="editor"
            tabSize={2}
            useSoftTabs
            editorProps={{ $blockScrolling: Infinity }}
          />
        </div>
        <div className="panel">
          <h5>AST</h5>
          <div className="output">
            <Ansi>{pretty}</Ansi>
          </div>
        </div>
      </div>
    )
  }
}
