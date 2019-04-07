import React from 'react'
import AceEditor from 'react-ace'
import throttle from 'lodash/throttle'
import debounce from 'lodash/debounce'
import 'brace/mode/elixir'
import 'brace/theme/textmate'
import { Callout, Checkbox } from '@blueprintjs/core'

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
    const { showOptions } = state

    return (
      <div className="code-editor">
        <AceEditor
          ref={e => this.editorComponent = e}
          mode="elixir"
          theme="textmate"
          value={state.code}
          onChange={this.onCodeChange}
          name="editor"
          tabSize={2}
          useSoftTabs
          editorProps={{ $blockScrolling: Infinity }}
        />
        {showOptions
        ? <Callout>
          <Checkbox checked={state.formatter} onChange={e => dispatch({ action: 'formatter', payload: e.target.checked })} label="Auto-format" />
          <Checkbox checked={state.code_is_ast} onChange={e => dispatch({ action: 'code_is_ast', payload: e.target.checked })} label="Source code is the AST" />
        </Callout> : null}
      </div>
    )
  }

  componentDidMount() {
    const { editor } = this.editorComponent
    const { dispatch } = this.props

    editor.commands.addCommand({
      name: "showOptions",
      bindKey: {win: "Ctrl-Alt-o", mac: "Command-Alt-o"},
      exec: () => dispatch({ action: 'showOptions', payload: !this.props.state.showOptions })
    })
    editor.commands.addCommand({
      name: "layoutNext",
      bindKey: {win: "Ctrl-Alt-n", mac: "Command-Alt-n"},
      exec: () => dispatch({ action: 'layoutNext' })
    })
    editor.commands.addCommand({
      name: "layoutPrev",
      bindKey: {win: "Ctrl-Alt-p", mac: "Command-Alt-p"},
      exec: () => dispatch({ action: 'layoutPrev' })
    })
  }

}
