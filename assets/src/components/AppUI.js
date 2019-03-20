import React from 'react'
import { Mosaic, MosaicWindow } from 'react-mosaic-component'
import { Navbar, Button } from '@blueprintjs/core'
import '@blueprintjs/core/lib/css/blueprint.css'
import 'react-mosaic-component/react-mosaic-component.css'

import { useLocalStorage } from '../hooks'
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

const INITIAL_LAYOUT = {
  direction: 'row',
  first: 'elixir',
  second: {
    direction: 'row',
    first: 'tokens',
    second: 'ast',
  },
  splitPercentage: 40,
}

export default function(props) {
  const [mosaic, setMosaic] = useLocalStorage('mosaic', INITIAL_LAYOUT);

  const renderTile = (id, path) => {
    const [Element, title] = ELEMENT_MAP[id]
    return (<MosaicWindow path={path} title={title} toolbarControls={[]}>
      <Element name={id} {...props} />
    </MosaicWindow>
    )
  }

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
        renderTile={renderTile}
        onChange={setMosaic}
        value={mosaic}
      />
    </div>
  )
}
