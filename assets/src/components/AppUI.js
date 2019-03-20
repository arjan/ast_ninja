import React from 'react'
import { Mosaic, MosaicWindow } from 'react-mosaic-component'
import { Navbar, Button } from '@blueprintjs/core'
import '@blueprintjs/core/lib/css/blueprint.css'
import 'react-mosaic-component/react-mosaic-component.css'

import CodeEditor from './CodeEditor'
import RawOutput from './RawOutput'

function Placeholder() {
  return <div>Placeholder</div>
}

const ELEMENT_MAP = {
  elixir: [CodeEditor, "Elixir code"],
  ast: [RawOutput, "AST"],
  tokens: [RawOutput, "Tokens"],
}


export default class extends React.Component {

  renderTile = (id, path) => {
    const [Element, title] = ELEMENT_MAP[id]
    return (<MosaicWindow path={path} title={title} toolbarControls={[]}>
      <Element name={id} {...this.props} />
    </MosaicWindow>
    )
  }

  render() {
    const { state, dispatch } = this.props

    return (
      <div className="app">
        <Navbar className="bp3-dark">
          <Navbar.Group align="left">
            <Navbar.Heading>
              AST Ninja
            </Navbar.Heading>
          </Navbar.Group>
        </Navbar>

        <Mosaic
          renderTile={this.renderTile}
          initialValue={{
            direction: 'row',
            first: 'elixir',
            second: {
              direction: 'row',
              first: 'tokens',
              second: 'ast',
            },
            splitPercentage: 40,
          }}
        />
      </div>
    )
  }
}
