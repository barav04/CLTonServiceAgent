(function () {
  "use strict";

  var config = window.DIGI1_CONFIG;
  var STORAGE_KEY = config.orgId + "_WEB_STORAGE";

  // onEmbeddedMessagingReady fires before a new conversation exists, and sendTextMessage
  // rejects until it does, so retry for up to SEND_ATTEMPTS * SEND_RETRY_MS.
  var SEND_ATTEMPTS = 20;
  var SEND_RETRY_MS = 1500;

  var body = document.body;
  var prompt = document.getElementById("prompt");
  var send = document.getElementById("send");
  var statusEl = document.getElementById("status");
  var toggle = document.getElementById("toggle-view");

  var ready = false;
  var pendingPrompt = null;

  // Forget the previous conversation before the chat script loads, so every page load
  // starts a new conversation instead of resuming the last one.
  function forgetConversation() {
    try {
      localStorage.removeItem(STORAGE_KEY);
    } catch (e) {
      /* storage unavailable */
    }
  }

  function setStatus(text, isError) {
    statusEl.textContent = text || "";
    statusEl.classList.toggle("is-error", !!isError);
  }

  function showConversation(show) {
    body.classList.toggle("is-chatting", show);
    toggle.textContent = show ? "Back to start" : "Open conversation";
  }

  function autoGrow() {
    prompt.style.height = "auto";
    prompt.style.height = Math.min(prompt.scrollHeight, 200) + "px";
    send.disabled = !prompt.value.trim();
  }

  function sendWhenConversationReady(text, attemptsLeft) {
    var util = window.embeddedservice_bootstrap.utilAPI;
    var sent = config.contextVariables.length
      ? util.sendTextMessage(text, config.contextVariables)
      : util.sendTextMessage(text);
    return Promise.resolve(sent).catch(function (err) {
      if (attemptsLeft <= 1) {
        throw err;
      }
      return new Promise(function (resolve) {
        setTimeout(resolve, SEND_RETRY_MS);
      }).then(function () {
        return sendWhenConversationReady(text, attemptsLeft - 1);
      });
    });
  }

  function ask(text) {
    text = (text || "").trim();
    if (!text) {
      return;
    }
    if (!ready) {
      pendingPrompt = text;
      setStatus("Connecting to digi1… your message will be sent shortly.");
      return;
    }
    send.disabled = true;
    setStatus("Sending…");
    sendWhenConversationReady(text, SEND_ATTEMPTS)
      .then(function () {
        prompt.value = "";
        autoGrow();
        setStatus("");
        showConversation(true);
      })
      .catch(function (err) {
        console.error("digi1 sendTextMessage failed", err);
        setStatus(
          "Couldn't reach digi1. Open the conversation and type your message there.",
          true
        );
        send.disabled = false;
      });
  }

  // Ends the current conversation (the chat's own End option is in the cropped header),
  // then reloads to a fresh conversation.
  function newChat() {
    var restart = function () {
      forgetConversation();
      window.location.reload();
    };
    try {
      Promise.resolve(
        window.embeddedservice_bootstrap.userVerificationAPI.clearSession(true)
      ).then(restart, restart);
    } catch (e) {
      restart();
    }
  }

  function initEmbeddedMessaging() {
    try {
      var bootstrap = window.embeddedservice_bootstrap;
      bootstrap.settings.language = config.language;
      bootstrap.settings.displayMode = "inline";
      bootstrap.settings.targetElement = document.getElementById("digi1-chat");
      bootstrap.init(config.orgId, config.deploymentName, config.siteUrl, {
        scrt2URL: config.scrt2Url
      });
    } catch (err) {
      console.error("Error loading Embedded Messaging: ", err);
      setStatus("Couldn't load the chat. Please refresh the page.", true);
    }
  }

  function loadChatScript() {
    var script = document.createElement("script");
    script.src = config.siteUrl + "/assets/js/bootstrap.min.js";
    script.onload = initEmbeddedMessaging;
    script.onerror = function () {
      setStatus("Couldn't load the chat. Please refresh the page.", true);
    };
    document.body.appendChild(script);
  }

  document
    .getElementById("composer")
    .addEventListener("submit", function (event) {
      event.preventDefault();
      ask(prompt.value);
    });

  prompt.addEventListener("input", autoGrow);
  prompt.addEventListener("keydown", function (event) {
    if (event.key === "Enter" && !event.shiftKey) {
      event.preventDefault();
      ask(prompt.value);
    }
  });

  Array.prototype.forEach.call(
    document.querySelectorAll(".chip"),
    function (chip) {
      chip.addEventListener("click", function () {
        ask(chip.getAttribute("data-prompt"));
      });
    }
  );

  toggle.addEventListener("click", function () {
    showConversation(!body.classList.contains("is-chatting"));
  });

  document.getElementById("new-chat").addEventListener("click", newChat);

  window.addEventListener("onEmbeddedMessagingReady", function () {
    ready = true;
    setStatus("");
    var queued = pendingPrompt || config.autoPrompt;
    pendingPrompt = null;
    if (queued) {
      setTimeout(function () {
        ask(queued);
      }, config.autoPromptDelayMs);
    }
  });

  forgetConversation();
  showConversation(!!config.autoPrompt);
  prompt.focus();
  loadChatScript();
})();
