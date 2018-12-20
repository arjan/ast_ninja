import React from 'react'
import debounce from 'lodash/debounce'
import Ansi from 'ansi-to-react'
import { channel } from 'socket'

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

  onCodeChange = ({ target }) => {
    this.setState({ code: target.value })
    this.update()
  }

  render() {
    const { code, pretty } = this.state
    return (
      <div className="explorer--wrapper">
        <textarea
          value={code}
          onChange={this.onCodeChange}
        />
        <div className="output">
          <Ansi>{pretty}</Ansi>
        </div>
      </div>
    )
  }
}
