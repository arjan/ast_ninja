import React from 'react'
import { Mosaic, MosaicWindow } from 'react-mosaic-component'
import { Navbar, Button, Checkbox } from '@blueprintjs/core'
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
  atom_free_tokens: [RawOutput, "Tokens (atom free)"],
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

function togglePanel(name, show, mosaic) {
  if (show) {
    return { direction: 'row', splitPercentage: 70, first: mosaic, second: name }
  } else {
    // remove it
    const traverse = (node) => {
      if (node.first === name) {
        return node.second
      }
      if (node.second === name) {
        return node.first
      }
      if (typeof node.first === 'object') {
        node.first = traverse(node.first)
      }
      if (typeof node.second === 'object') {
        node.second = traverse(node.second)
      }
      return node
    }

    const result = traverse(mosaic)
    return typeof result === 'string' ? result : { ...result }
  }
}


function renderRemainingButtons(mosaic, setMosaic) {
  const rendered = []
  if (typeof mosaic === 'string') {
    rendered.push(mosaic)
  } else {
    const traverse = ({ first, second }) => {
      if (typeof first === 'string') {
        rendered.push(first)
      } else {
        traverse(first)
      }
      if (typeof second === 'string') {
        rendered.push(second)
      } else {
        traverse(second)
      }
    }
    traverse(mosaic, rendered)
  }

  return Object.keys(ELEMENT_MAP).map(
    k => <Checkbox
           key={k}
           label={ELEMENT_MAP[k][1]}
           checked={rendered.indexOf(k) >= 0}
           onChange={e => setMosaic(togglePanel(k, e.target.checked, mosaic))}
    />
  )
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
        <Navbar.Group align="right">
          {renderRemainingButtons(mosaic, setMosaic)}
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
