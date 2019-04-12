import { Elm } from './Main.elm';

let currState = {
  selectedContent: 0.0
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
    const selectNum = request.selectedContent.replace(',', '');
    fetch('https://tw.rter.info/capi.php')
      .then(function(response) {
        return response.json()
      })
      .then(function(myJson) {
        const {
          USDJPY: { Exrate: ExrateJPY },
          USDTWD: { Exrate: ExrateTWD }
        } = myJson
        const result = selectNum * (ExrateTWD / ExrateJPY)
        app.ports.selected.send({ selectedContent: +result.toFixed(1)})
      });
  }
})
