# Claude Code Chrome Integration (VSCode)

Connect Claude Code in VSCode to your Chrome browser for browser automation, testing, debugging, and data extraction.

## Prerequisites

- Google Chrome or Microsoft Edge
- [Claude in Chrome extension](https://chromewebstore.google.com/detail/claude/fcoeoabgfenejglbffodgkkbkcdhcgfn) v1.0.36+
- Claude Code VSCode extension v2.0.73+
- Paid Anthropic plan (Pro, Max, Team, or Enterprise)

> Chrome integration is **not** available through Bedrock, Vertex AI, or Foundry. You need a direct claude.ai account.

## Setup

No setup required in VSCode beyond installing the Chrome extension. The VSCode extension auto-detects it.

If the extension isn't detected on first attempt, restart Chrome so it picks up the native messaging host config.

## Usage

### Basic syntax

Use `@browser` in the Claude Code prompt box:

```
@browser go to localhost:3000 and check the console for errors
```

You can also open the **attachment menu** in the prompt box to select specific browser tools (open tab, read page content, etc.).

### Available browser tools

Type `/mcp` in the prompt box and select `claude-in-chrome` to see the full list of available browser tools.

## Key behaviors

- **New tabs only** — Claude opens new tabs for all browser tasks. It does not interact with existing open tabs.
- **Shared login state** — Claude uses your browser's existing sessions. Any site you're logged into is accessible.
- **Manual intervention** — Claude pauses and asks you to handle login pages and CAPTCHAs manually.
- **Real-time visibility** — all browser actions run in a visible Chrome window so you can watch.

## Example workflows

### Test a local web app

```
@browser open localhost:3000, try submitting the login form with invalid data,
and check if the error messages appear correctly
```

### Debug with console logs

```
@browser open the dashboard page and check the console for any errors when the page loads
```

### Verify UI changes

```
@browser open localhost:3000/settings and verify the new form layout matches the mockup
```

### Extract data from a page

```
@browser go to the product listings page and extract the name, price,
and availability for each item. Save the results as a CSV file.
```

### Automate form filling

```
@browser I have contact data in contacts.csv. For each row, go to crm.example.com,
click "Add Contact", and fill in the name, email, and phone fields.
```

### Work with authenticated apps

```
@browser open my Google Doc at docs.google.com/document/d/abc123
and draft a project update based on recent commits
```

### Record a demo

```
@browser record a GIF showing the checkout flow from adding an item
to the cart through to the confirmation page
```

## Troubleshooting

| Problem | Fix |
|---|---|
| Extension not detected | Verify extension is installed and enabled in `chrome://extensions`. Restart Chrome. |
| Browser not responding | Check for modal dialogs (alert/confirm/prompt) blocking the page. Dismiss manually. |
| Connection drops mid-session | Chrome extension service worker went idle. Restart the extension in `chrome://extensions`. |
| Named pipe conflict (Windows) | Close other Claude Code sessions that might be using Chrome, then restart. |

### Native messaging host config (Windows)

If connection fails, verify the registry key exists:

```
HKCU\Software\Google\Chrome\NativeMessagingHosts\com.anthropic.claude_code_browser_extension
```

For Edge:

```
HKCU\Software\Microsoft\Edge\NativeMessagingHosts\com.anthropic.claude_code_browser_extension
```

## Limitations

- Beta feature — Chrome and Edge only. Brave, Arc, and other Chromium browsers are not supported.
- WSL is not supported.
- Cannot interact with existing open tabs — always opens new ones.
- Not available on free-tier Anthropic accounts.
