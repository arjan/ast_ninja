import React from 'react'
import AceEditor from 'react-ace'
import throttle from 'lodash/throttle'
import 'brace/mode/elixir'
import 'brace/theme/textmate'

export default class extends React.Component {

  update = throttle(() => {
    this.props.dispatch({ action: 'parse' })
  }, 100)

  onCodeChange = (payload) => {
    this.props.dispatch({ action: 'code', payload })
    this.update()
  }

  render() {
    const { state, dispatch } = this.props

    return (
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
    )
  }
}
