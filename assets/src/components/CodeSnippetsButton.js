import React from 'react'
import { Popover, Menu, MenuItem, Button } from '@blueprintjs/core'

const SNIPPETS = [
  ['basic module', `# this is a demo
defmodule Greeting do
  def hello do
    IO.puts "Hello, world!"
  end
end
  `],
  ['Expression #1', 'a == "2"'],
]

export default class extends React.Component {
  render() {
    const items = SNIPPETS.map(
      ([ title, payload ]) =>
        <MenuItem
          key={title}
          text={title}
          onClick={() => {
            this.props.dispatch({ action: 'code', payload })
            this.props.dispatch({ action: 'parse' })
          }}
        />)

    return (
      <Popover>
        <Button minimal icon="code" rightIcon="chevron-down" />
        <Menu>{items}</Menu>
      </Popover>
    )
  }
}
