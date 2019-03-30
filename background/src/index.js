import { Elm } from './Main.elm';

let currState = {
  clicks: 0,
  selectedContent: ''
}

const app = Elm.Main.init({
  flags: currState
});

// the currently connected ports
const listeners = new Set()

chrome.runtime.onConnect.addListener(port => {
  console.assert(port.name === 'broadcast')

  listeners.add(port)

  // whenever a new listener connects, we immediately tell them
  // the state so they can initialize
  port.postMessage(currState)

  port.onDisconnect.addListener(() => {
    listeners.delete(port)
  })
})

function broadcast(state) {
  currState = state
  for (const port of listeners) {
    port.postMessage(state)
  }
}

app.ports.broadcast.subscribe(state => {
  broadcast(state)
})

chrome.runtime.onMessage.addListener((request, sender) => {
  if (request.kind === 'clicked') {
    app.ports.clicked.send(null)
  } else if (request.kind === 'selected') {
    app.ports.selected.send({ clicks: 0, selectedContent: request.selectedContent })
  }
})
