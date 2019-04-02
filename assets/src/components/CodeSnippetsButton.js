import React from 'react'
import { Popover, Menu, MenuItem, Button } from '@blueprintjs/core'

const SNIPPETS = [
  ['Elixir module', `# this is a demo
defmodule Greeting do
  def hello do
    IO.puts "Hello, world!"
  end
end
  `],
  ['Bubblescript', `@intent greeting(match: "hello|hallo|hi|hey|wazzup")

dialog main do
  say "Hi there!"
end

dialog trigger: @greeting do
  say "👋 Hello to you too!"
end
  `],
  ['Filter expression #1', 'a == "2"'],
  ['Filter expression #2', 'a == "2" and b == "2"'],
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
