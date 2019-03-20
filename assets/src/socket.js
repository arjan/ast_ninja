import { Socket } from 'phoenix'

export const socket = new Socket('/socket', {})
socket.connect()

export const channel = socket.channel('parser', {})
channel.join()
  .receive('ok', resp => { console.log('Joined successfully', resp) })
  .receive('error', resp => { console.log('Unable to join', resp) })
