# digi1 website

A static website that hosts the digi1 Agentforce Service Agent full page, using Enhanced Chat v2 in inline mode. No build step: plain HTML, CSS and JavaScript that any static host can serve.

| File         | Purpose                                                                                               |
| ------------ | ----------------------------------------------------------------------------------------------------- |
| `index.html` | Page markup: top bar, landing view (greeting, single input, suggestion chips), conversation container |
| `styles.css` | Layout and theme. The chat renders in a Salesforce iframe, so only the page around it is styled here  |
| `config.js`  | Everything org-specific: org ID, deployment, site URL, SCRT URL, auto prompt, context variables       |
| `app.js`     | Loads the Enhanced Chat script, sends the automatic prompt, single-input landing view, New chat       |

## Behaviour

- **Every page load starts a new conversation** and immediately sends `autoPrompt` ("main menu"), so visitors land on the menu card.
- **New chat** ends the conversation in Salesforce (`clearSession(true)`) and reloads into a new one.
- **Back to start** shows the landing view with one input bar and suggestion chips. Anything sent from there goes to the same conversation.
- **Context variables** in `config.contextVariables` are sent with the first message (the agent variable needs API write access).
- The chat's own header bar is cropped (`--chat-header-height` in `styles.css`) so the conversation reads as part of the page.

## Salesforce setup per website domain

Enhanced Chat only works on domains the org trusts. For **each** domain the site is served from (for example `https://www.example.com`), add it in two places:

1. **CORS allowlist** – lets the page load the deployment settings from Salesforce.
   Setup > CORS > New, Origin URL Pattern `https://www.example.com`.
   As metadata: `force-app/main/default/corsWhitelistOrigins/*.corsWhitelistOrigin-meta.xml`.
2. **Trusted domains for framing on the chat site** – lets the page embed the chat iframe.
   Add the domain to `siteIframeWhiteListUrls` in
   `force-app/main/default/sites/ESW_digi1_Web_1793472238256.site-meta.xml` and deploy it.
   (Setup: Digital Experiences > the `ESW_digi1_Web_…` site > Builder > Settings > Security & Privacy.)
   Use the bare host for HTTPS sites (`www.example.com`). An entry without a scheme only matches HTTPS pages, so plain-HTTP origins need the scheme (`http://localhost:8080`).

`http://localhost:8080` is already set up in this org for local testing. Remove both entries before going to production if you don't need them.

CORS changes can take several minutes to reach every Salesforce server; until then the chat can stay on its loading screen ("HELLO").

## Run locally

```bash
cd website
python3 -m http.server 8080 --bind 127.0.0.1
```

Open http://localhost:8080. Any static server works, as long as it serves on port 8080 (or you add your port to both lists above).

## Deploy

Upload the four files to any static host that serves HTTPS (Netlify, Vercel, Azure Static Web Apps, S3 + CloudFront, Nginx, an existing web server). Then add the site's domain to both Salesforce lists above.

To point the site at a different org or deployment, change `config.js` using the values from Setup > Embedded Service Deployments > (deployment) > Code Snippet, and repeat the domain setup in that org.

## Known limits

- The automatic prompt waits `autoPromptDelayMs` (6 s) after the chat is ready, because a message sent before the agent joins is not answered and the page gets no join event. Increase it if the menu sometimes doesn't appear.
- Refreshing the page starts a new conversation but leaves the previous one open in Salesforce until it times out; only New chat ends it.
- Cards (Custom Lightning Types) render inside the chat iframe and follow the chat's branding, set in Setup > Embedded Service Deployments > digi1 Web > Branding.
