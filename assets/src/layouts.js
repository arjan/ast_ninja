
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
  panel('to_string'),
  panel('filter_demo'),
  'elixir',
  panel('int_parser'),
  panel('json_ast'),
]

export const INITIAL_LAYOUT = LAYOUTS[0]

let layoutIndex = 0

export function nextLayout() {
  layoutIndex = (layoutIndex + 1) % LAYOUTS.length
  return LAYOUTS[layoutIndex]
}

export function prevLayout() {
  layoutIndex = (layoutIndex - 1 + LAYOUTS.length) % LAYOUTS.length
  return LAYOUTS[layoutIndex]
}
