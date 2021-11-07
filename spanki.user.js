// ==UserScript==
// @name         SpAnki
// @namespace    SpAnki
// @version      0.1
// @description  Parse Google Docs spelling errors
// @author       RevoGen
// @match        https://docs.google.com/*
// @grant        unsafeWindow
// ==/UserScript==


let icon = `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-clipboard-plus" viewBox="0 0 16 16">
  <path fill-rule="evenodd" d="M8 7a.5.5 0 0 1 .5.5V9H10a.5.5 0 0 1 0 1H8.5v1.5a.5.5 0 0 1-1 0V10H6a.5.5 0 0 1 0-1h1.5V7.5A.5.5 0 0 1 8 7z"/>
  <path d="M4 1.5H3a2 2 0 0 0-2 2V14a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V3.5a2 2 0 0 0-2-2h-1v1h1a1 1 0 0 1 1 1V14a1 1 0 0 1-1 1H3a1 1 0 0 1-1-1V3.5a1 1 0 0 1 1-1h1v-1z"/>
  <path d="M9.5 1a.5.5 0 0 1 .5.5v1a.5.5 0 0 1-.5.5h-3a.5.5 0 0 1-.5-.5v-1a.5.5 0 0 1 .5-.5h3zm-3-1A1.5 1.5 0 0 0 5 1.5v1A1.5 1.5 0 0 0 6.5 4h3A1.5 1.5 0 0 0 11 2.5v-1A1.5 1.5 0 0 0 9.5 0h-3z"/>
</svg>`;

function modifyToolbar() {
  if (document.getElementById("spanki-button") != null) {
    return;
  }
  let toolbar = document.getElementsByClassName("kix-spell-bubble")[0];
  let button = document.createElement("div");
  button.setAttribute("id", "spanki-button");
  button.setAttribute(
    "class",
    "kix-spell-bubble-option docs-material-button-flat-default docs-material-button kix-spell-bubble-more-options"
  );
  button.innerHTML = icon.trim();
  toolbar.appendChild(button);

  button.addEventListener("click", onClick);
}

function onClick(event) {
  let suggestion = document.getElementsByClassName(
    "kix-spell-bubble-suggestion-text"
  )[0].textContent;
  let regex = new RegExp(String.raw`(?<=\()\S*(?=\))`);
  let email = document
    .getElementsByClassName("gb_Ma")[0]
    .getAttribute("aria-label");
  email = email.match(regex)[0];

  fetch("https://cscigpu06:5000/api/docs/add_word", {
    method: "POST",
    mode: "no-cors",
    cache: "no-cache",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      word: suggestion,
      email: email,
    }),
  });

  console.log(suggestion);
  console.log(email);
}

var MutationObserver = window.MutationObserver || window.WebKitMutationObserver;

var observer = new MutationObserver(function (mutations, observer) {
  let triggered = false;
  for (let mutation of mutations) {
    let target = mutation.target;

    if (
      target.classList.contains("kix-spell-bubble") &&
      target.style.display != "none"
    ) {
      triggered = true;
      break;
    }
  }
  if (triggered) {
    console.log("triggered");
    modifyToolbar();
  }
});


observer.observe(document, {
  attributes: true,
  subtree: true,
  //...
});

