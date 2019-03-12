import React from 'react'
import throttle from 'lodash/throttle'
import Ansi from 'ansi-to-react'
import { channel } from 'socket'
import AceEditor from 'react-ace'

import PersistSplitPane from './PersistSplitPane'

import 'brace/mode/elixir'
import 'brace/theme/textmate'

const CODE = `# this is a demo
defmodule Greeting do
  def hello do
    IO.puts "Hello, world!"
  end
end
`

export default class Component extends React.Component {
  state = {
    code: CODE,
    ast: '',
    tokens: '',
    astError: null,
    tokensError: null
  }

  componentWillMount() {
    this.update()
  }

  update = throttle(() => {
    const { code } = this.state
    channel.push('parse', { code }).receive('ok', state => {
      this.setState({ ast: "", tokens: "", tokensError: null, astError: null, ...state })
    })
  }, 100)

  onCodeChange = (code) => {
    this.setState({ code })
    this.update()
  }

  error(error) {
    return error
         ? <div className="error">Error on line {error.line}: {error.message}</div>
         : null
  }

  render() {
    const { code, tokens, tokensError, ast, astError } = this.state
    return (
      <div className="explorer--wrapper">
        <PersistSplitPane name='m' split="vertical" minSize={50} defaultSize={400}>

          <div className="panel">
            <h5>Elixir Code</h5>
            <AceEditor
              mode="elixir"
              theme="textmate"
              value={code}
              onChange={this.onCodeChange}
              name="editor"
              tabSize={2}
              useSoftTabs
              editorProps={{ $blockScrolling: Infinity }}
            />
          </div>

          <PersistSplitPane name='n' split="vertical" minSize={50} defaultSize={400}>
            <div className="panel">
              <h5>Tokens</h5>
              {this.error(tokensError) || <div className="output"><Ansi>{tokens}</Ansi></div>}
            </div>
            <div className="panel">
              <h5>AST</h5>
              {this.error(astError) || <div className="output"><Ansi>{ast}</Ansi></div>}
            </div>
          </PersistSplitPane>
        </PersistSplitPane>

      </div>
    )
  }
}
