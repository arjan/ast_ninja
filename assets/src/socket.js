import { Socket } from 'phoenix'

export const socket = new Socket('/socket', {})
socket.connect()

export function joinChannel(onConnect) {
  const channel = socket.channel('parser', {})
  channel.join().receive('ok', () => onConnect(channel)).receive('error', resp => { console.log('Unable to join', resp) })
}
