import React from 'react'
import SplitPane from 'react-split-pane'

export default class extends React.Component {
  render() {
    const { name, children, ...props } = this.props

    return (
      <SplitPane {...props}
        defaultSize={ parseInt(localStorage.getItem(name), 10) || 400 }
        onChange={ size => localStorage.setItem(name, size) }>
        {children}
      </SplitPane>
    )
  }
}
