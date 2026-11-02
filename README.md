## know-your-code

I'm a software engineering student. New frontier models keep landing, each faster and more powerful than the last, and AI is moving faster than a student can understand. I was building things, but I couldn't understand the code.

I don't think I'm alone in that.

So I built a Claude Code plugin with guardrails: before you push, you explain what changed and why. Code stays fast. You keep learning.

![know-your-code blocks a git push until you explain the diff](assets/demo.gif)

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

You code like you always do. When you try to `git push` or open a PR, the gate stops you:

```
❯ push this

⛔ know-your-code: explain before you ship
   3 files changed · +142 −18

   Q1. Why does retryFetch() back off instead of retrying instantly?
   Q2. What happens if the Redis call in queue.ts throws?
```

Answer in your own words. Get it right, you ship. Get it wrong, you learn why, then you ship.

### Levels

| Level | When | What |
|---|---|---|
| `easy` | Before push | Multiple choice with hints. Pick, then say why in one line. |
| `medium` | Before push | Open questions on what changed, why, and what breaks. **Default.** |
| `hard` | Before coding **and** before push | Pick between tradeoffs, plan the build, then check the build against your plan. |

Start easy. Graduate to hard.

### Commands

In Claude Code these are slash commands. In other agents, just say them ("kyc hard").

| Command | Does |
|---|---|
| `/kyc` | Quiz me on the current diff now |
| `/kyc explain` | Walk me through what changed and why |
| `/kyc easy` · `medium` · `hard` | Set difficulty |
| `/kyc off` | Skip the gate once (logged) |

### Other agents

The quiz is an [Agent Skill](https://agentskills.io) (`skills/know-your-code/SKILL.md`), so any agent that reads skills can run it. The gate is a hook, so it only works where the agent has hooks.

| Agent | Gate (blocks push) | Quiz skill | Hard-mode plan nudge | Status |
|---|---|---|---|---|
| Claude Code | ✅ `PreToolUse` | ✅ | ✅ | tested |
| Codex | ✅ `PreToolUse` | ✅ | ✅ | untested |
| Cursor | ✅ `beforeShellExecution` | via `AGENTS.md` | ❌ (Cursor prompt hooks can't add context) | untested |
| Others (Windsurf, Cline, …) | ❌ | via `AGENTS.md` | ❌ | soft rule only |

**Codex**

```bash
codex plugin marketplace add MinitJain/know-your-code
codex plugin add know-your-code@know-your-code
```

Then run `codex`, open `/hooks`, review and trust the hooks, and start a new thread. Codex skips hooks it hasn't trusted.

**Cursor**

```bash
git clone https://github.com/MinitJain/know-your-code ~/.know-your-code
```

Copy `hooks/cursor-hooks.json` to `~/.cursor/hooks.json` (or merge its `beforeShellExecution` entry into yours) and replace `KYC_DIR` with the absolute clone path, e.g. `/Users/you/.know-your-code`. Copy `AGENTS.md` into your project so the agent knows how to run the quiz.

**Anything else**

Copy `AGENTS.md` into your project. Without hooks nothing stops the push, so the agent follows the rule on its own.

### Why not just use Learning mode?

Claude Code's Learning mode nudges. It doesn't stop you. Other tools make you write every line by hand. know-your-code stays out of your way while you build, and only stands between you and shipping.

### How the gate works

- State lives in `.kyc/` at your repo root (self-gitignored).
- A pass is tied to the exact commit. New commit, new quiz.
- Needs `jq`. If `jq` is missing the gate fails open and warns.
- Catches `git push` and `gh pr create`, also inside chains like `git add . && git push`. Not caught: shell aliases (`gp`) and commands wrapped in `sh -c '...'`.
- It is an honor system: you can always delete the hook. The point is the habit, not the lock.

### Develop

```
claude --plugin-dir ~/know-your-code
bash tests/gate.test.sh
claude plugin validate .
```

### License

MIT
