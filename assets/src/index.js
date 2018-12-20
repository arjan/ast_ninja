import React from 'react'
import { render } from 'react-dom'

import 'css/app.scss'
import 'phoenix_html'
import './socket'

import App from 'components/App'

render(<App />, document.getElementById('root'))
