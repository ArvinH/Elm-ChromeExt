require('./index.css')

const mountNode = document.createElement('div')
document.body.prepend(mountNode)

import { Elm } from './Main.elm';

let app

// document.addEventListener('click', () => {
//   chrome.runtime.sendMessage({ kind: 'clicked' })
// })

document.addEventListener('mouseup', () => {
  const selectedContent = window.getSelection().toString();
  if (selectedContent && selectedContent!== '') {
    chrome.runtime.sendMessage({ kind: 'selected', selectedContent })
  }
});

const port = chrome.runtime.connect({ name: 'broadcast' })
port.onMessage.addListener(state => {
  if (!app) {
    app = Elm.Main.init({
      node: mountNode,
      flags: state
    })
    return
  }
  app.ports.onState.send(state)
})
