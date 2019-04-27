require('./index.css')

const mountNode = document.createElement('div');
document.body.append(mountNode);

import { Elm } from './Main.elm';

let app;

// document.addEventListener('click', () => {
//   chrome.runtime.sendMessage({ kind: 'clicked' })
// })

document.addEventListener('mouseup', () => {
  const selectedObj = window.getSelection();
  const selectedNode = selectedObj.anchorNode;
  const selectedParentEl = selectedNode.parentElement;
  const selectedContent = selectedObj.toString();
  if (!selectedContent) {
    mountNode.style.display = 'none';
    chrome.runtime.sendMessage({ kind: 'selected', selectedContent: '' });
    return;
  }
  const selectedPosition = {
    top: selectedParentEl.getBoundingClientRect().top,
    left: selectedParentEl.getBoundingClientRect().left
  };
  mountNode.style.left = `${selectedPosition.left + window.scrollX}px`;
  mountNode.style.top = `${selectedPosition.top + window.scrollY +40}px`;
  mountNode.style.display = 'block';
  if (selectedContent && selectedContent!== '') {
    chrome.runtime.sendMessage({ kind: 'selected', selectedContent });
  }
});

const port = chrome.runtime.connect({ name: 'broadcast' });
port.onMessage.addListener(state => {
  if (!app) {
    app = Elm.Main.init({
      node: mountNode,
      flags: state
    });
    return;
  }
  app.ports.onState.send(state);
})
