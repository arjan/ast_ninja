export const INITIAL_LAYOUT = {
  direction: 'row',
  first: 'elixir',
  second: {
    direction: 'row',
    first: 'tokens',
    second: 'ast',
  },
  splitPercentage: 40,
}

function panel(second) {
  return {
    direction: 'row',
    first: 'elixir',
    second,
    splitPercentage: 50,
  }
}

export const LAYOUTS = [
  panel('ast'),
  panel('tokens'),
]
