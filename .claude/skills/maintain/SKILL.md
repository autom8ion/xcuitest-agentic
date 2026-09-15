---
name: maintain
description: /maintain [what changed in the app] — run a full proactive maintenance pass (status, heal, optional coverage, audits) by delegating to xcuitest-maintainer.
---

# /maintain

Usage: `/maintain` or `/maintain the checkout flow now supports Apple Pay`.

Call the `xcuitest-maintainer` subagent, passing along whatever the user said changed (or nothing, if this is a routine sweep). Relay its punch list back to the user.
