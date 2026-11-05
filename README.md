## know-your-code

Build at AI speed without becoming a stranger to your own code.

know-your-code is a learning layer for AI coding agents. It keeps implementation moving, but surfaces the important decisions, tradeoffs, and risks while the work is happening—not only after a giant diff is finished.

> AI writes the code. You stay in the loop.

![know-your-code shows an in-flow learning checkpoint](assets/demo.gif)

### Install

**Claude Code** (send these as two separate prompts):

```
/plugin marketplace add MinitJain/know-your-code
```

```
/plugin install know-your-code@know-your-code
```

Needs `git` and `jq` on your PATH. More agents: see [Other agents](#other-agents).

### How it works

The learning loop has three speeds:

1. **Passive checkpoint** — after a meaningful code change, the agent gives a short summary: what changed, why, and one risk. No response is required.
2. **Decision checkpoint** — before a consequential choice, you choose between approaches or ask for more context.
3. **Ship checkpoint** — before `git push` or `gh pr create`, the existing diff review makes sure you can explain what you are shipping.

The system is deliberately selective. It does not quiz every tool call or interrupt routine work.

```
❯ add password reset

KYC · decision checkpoint
Where should reset tokens live?

a) A separate table — easier to revoke and audit
b) A signed token — fewer database reads, harder to invalidate

Choose a direction, or ask for more context.

...agent implements the feature...

KYC · passive checkpoint
Implemented the request flow. Tokens are hashed, expire after 15 minutes,
and are invalidated after use. Remaining risk: account-enumeration through
reset-request errors.
```

### Levels

| Level | During implementation | Before push |
|---|---|---|
| `easy` | Short summaries; decisions include plain-language options | Three multiple-choice questions with hints |
| `medium` | Summaries plus one open question for important decisions. **Default.** | Three focused questions: what, why, and what breaks |
| `hard` | Compare approaches, write a 5–10 line plan, then check meaningful changes against it | Explain plan/build drift and one failure mode |

Start with `easy`. Use `hard` when you are learning a new area or shipping a risky feature.

### Commands

In Claude Code these are slash commands. In other agents, just say them (for example, "kyc hard").

| Command | Does |
|---|---|
| `/kyc` | Run a checkpoint on the current work |
| `/kyc explain` | Walk through what changed, why, data flow, and risks |
| `/kyc easy` · `medium` · `hard` | Set the learning intensity |
| `/kyc off` | Skip the ship checkpoint once (logged) |

### Other agents

The learning loop is an [Agent Skill](https://agentskills.io) (`skills/know-your-code/SKILL.md`). Hooks add passive checkpoints where the agent supports post-tool hooks; `AGENTS.md` provides the same behavior as a soft rule everywhere else.

| Agent | Ship gate | In-flow checkpoints | Status |
|---|---|---|---|
| Claude Code | ✅ `PreToolUse` | ✅ `PostToolUse` | supported |
| Codex | ✅ `PreToolUse` | ✅ `PostToolUse` | supported |
| Cursor | ✅ `beforeShellExecution` | via `AGENTS.md` | soft in-flow support |
| Others | via `AGENTS.md` | via `AGENTS.md` | soft rule |

**Codex**

```bash
codex plugin marketplace add MinitJain/know-your-code
codex plugin add know-your-code@know-your-code
```

Then run `codex`, open `/hooks`, review and trust the hooks, and start a new thread.

**Cursor**

```bash
git clone https://github.com/MinitJain/know-your-code ~/.know-your-code
```

Copy `hooks/cursor-hooks.json` to `~/.cursor/hooks.json` and replace `KYC_DIR` with the absolute clone path. Copy `AGENTS.md` into your project so the agent follows the in-flow protocol.

**Anything else**

Copy `AGENTS.md` into your project. Without hooks, checkpoints are still part of the agent instructions, but the ship gate cannot block the shell.

### Product principles

- Maximize understanding per interruption.
- Explain important decisions before implementation, not every line after it.
- Keep routine work fast.
- Ask the developer to reason; never pretend the agent's explanation is theirs.
- Fail open if the learning layer is unavailable.
- Keep the final ship checkpoint as a safety net, not the whole product.

### How the gate works

- State lives in `.kyc/` at the repo root (self-gitignored).
- A pass is tied to the exact commit. New commit, new ship checkpoint.
- The in-flow hook only prompts when the working diff changes; it stores a hash in `.kyc/` so repeated tool calls stay quiet.
- Needs `jq`. If `jq` is missing, the hook fails open and warns.
- Catches `git push` and `gh pr create`, including chains like `git add . && git push`.
- It is an honor system: you can always use `/kyc off`. The point is the habit, not the lock.

### Develop

```
claude --plugin-dir ~/know-your-code
bash tests/gate.test.sh
claude plugin validate .
```

### License

MIT
