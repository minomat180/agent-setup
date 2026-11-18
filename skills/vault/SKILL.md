---
name: vault
description: Use a stored secret (API key, token, password) in a command without ever seeing its value. Use whenever a task needs a credential - never ask mino to paste one into the chat and never read keychain items directly.
---

# vault

Secrets live in the macOS login keychain under the `pi-vault` service. Each read
asks mino for Touch ID, naming the secret and your reason, so a read you don't
explain well will be denied.

List the names (never values):

```bash
pi-vault list
```

Run one command with a secret:

```bash
vault-run OPENAI_API_KEY "list models to check the key works" -- \
  sh -c 'curl -sH "Authorization: Bearer $PI_VAULT_SECRET" https://api.openai.com/v1/models'
```

- The secret is in `$PI_VAULT_SECRET` for that one process only. Reference it
  inside `sh -c '...'` with single quotes, so your shell never expands it.
- Output is merged (stderr into stdout) and the value is replaced with
  `[REDACTED]`. Don't try to get around that: no `echo`, `base64`, writing it to
  files, or passing it to anything but the intended service.
- A missing secret: tell mino to add it themself with `pi-vault set NAME`. Never
  set it for them from a value in the chat.
- Every attempt is logged to `~/.local/state/pi-vault/audit.log`.
