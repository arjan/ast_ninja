import React, { useEffect } from 'react'
import { Mosaic, MosaicWindow } from 'react-mosaic-component'
import { Navbar, Button, Checkbox, Popover, Menu, MenuItem } from '@blueprintjs/core'
import '@blueprintjs/core/lib/css/blueprint.css'
import 'react-mosaic-component/react-mosaic-component.css'

import { useLocalStorage } from '../hooks'
import CodeEditor from './CodeEditor'
import RawOutput from './RawOutput'
import JsonAST from './JsonAST'
import CodeSnippetsButton from './CodeSnippetsButton'

function Placeholder() {
  return <div>Placeholder</div>
}

const ELEMENT_MAP = {
  elixir: [CodeEditor, "Elixir code", CodeSnippetsButton],
  ast: [RawOutput, "AST"],
  tokens: [RawOutput, "Tokenizer"],
  existing_atom_tokens: [RawOutput, "Tokenizer (existing atoms)"],
  safe_atom_tokens: [RawOutput, "Tokenizer (safe atoms)"],
  safe_ast: [RawOutput, "AST (safe atoms)"],
  json_ast: [JsonAST, "AST (interactive)"],
  filter_demo: [RawOutput, "AST → SQL demo"],
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

function getEnabledPanels(mosaic) {
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
  return rendered
}

function renderRemainingButtons(mosaic, onChange) {
  const rendered = getEnabledPanels(mosaic)
  const items = Object.keys(ELEMENT_MAP)
                      .filter(k => rendered.indexOf(k) == -1)
                      .map(
                        k => <MenuItem
                               key={k}
                               text={ELEMENT_MAP[k][1]}
                               onClick={() => {
                                 onChange(togglePanel(k, true, mosaic))
                               }}
                        />
                      )
  if (!items.length) {
    return null
  }
  return (
    <Popover>
      <Button rightIcon="chevron-down">Add…</Button>
      <Menu>{items}</Menu>
    </Popover>
  )
}

export default function(props) {
  const [mosaic, setMosaic] = useLocalStorage('mosaic', INITIAL_LAYOUT);

  const dispatchParsers = (mosaic) => {
    props.dispatch({ action: 'parsers', payload: getEnabledPanels(mosaic).filter(p => p !== 'elixir') })
    props.dispatch({ action: 'parse' })
  }

  useEffect(() => {
    if (props.state.parsers === null) dispatchParsers(mosaic)
  })

  const onChange = mosaic => {
    dispatchParsers(mosaic)
    setMosaic(mosaic)
  }

  const renderTile = (id, path) => {
    const [Element, title, Extra] = ELEMENT_MAP[id]

    const controls = []
    if (Extra) {
      controls.push(<Extra key="extra" {...props} />)
    }

    controls.push(<Button key="remove" minimal icon="cross" onClick={e => onChange(togglePanel(id, false, mosaic))} />)

    return (<MosaicWindow
              path={path}
              title={title}
              toolbarControls={controls}>
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
          {renderRemainingButtons(mosaic, onChange)}
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
