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
    pretty: '',
    error: null
  }

  update = debounce(() => {
    const { code } = this.state
    channel.push('parse', { code }).receive('ok', ({ error, pretty }) => {
      console.log('pretty', pretty)
      if (error) {
        this.setState({ error })
      } else {
        this.setState({ pretty, error: null })
      }
    })
  }, 400)

  onCodeChange = (code) => {
    this.setState({ code })
    this.update()
  }

  render() {
    const { code, error, pretty } = this.state
    return (
      <div className="explorer--wrapper">
        <div className="panel">
          <h5>Elixir Code</h5>
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
          {error
           ? <div className="error">Error on line {error.line}: {error.message}</div>
           : <div className="output"><Ansi>{pretty}</Ansi></div>}
        </div>
      </div>
    )
  }
}
