## know-your-code

I'm a software engineering student. Every few months a new frontier model lands, faster and more powerful than the last. AI moves faster than a student can understand, and I stopped understanding my own code, especially when it's complex or new to me.

I don't think I'm alone in that.

So I built a Claude Code plugin that makes sure you learn something every time you ship: before you push, you explain what changed and why.

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

### Teaching-first build flow

The skill now teaches during the build, not only at shipping time. For a non-trivial task it first maps the relevant code and assumptions, proposes a small plan, explains unfamiliar concepts when they become relevant, verifies meaningful increments, and ends with a knowledge-transfer summary. It stays autonomous between those moments and does not interrupt for boilerplate. Local learning context lives in the ignored `.kyc/` directory: `profile.md`, `concepts.md`, `decisions.md`, and optional plans.

### Pair mode

A quiz at push time comes after the thinking. Pair mode moves some of it into the build. Turn it on with `/kyc pair`. At most 3 times per task, one at a time, Claude stops and makes you go first:

| Moment | You | Then Claude |
|---|---|---|
| Bug | Give your best guess at the cause | Argues against it once, then checks |
| Design choice | Pick from 2–3 options and say why | Argues against it once, recommends, builds |
| Before a test or build | Predict what happens | Runs it, compares |

No stops for boilerplate or formatting. Say "skip this checkpoint" or "pause pair mode" any time; it's logged. Each stop goes into `.kyc/journal-<branch>.md`, and the push quiz asks about your own calls first ("you predicted 2 failures, there was 1, why?"). On `hard`, you also write the one function that carries the feature's core decision.

### Commands

In Claude Code these are slash commands. In other agents, just say them ("kyc hard").

| Command | Does |
|---|---|
| `/kyc` | Quiz me on the current diff now |
| `/kyc explain` | Walk me through what changed and why |
| `/kyc profile` | Read or update my local learning context |
| `/kyc easy` · `medium` · `hard` | Set difficulty |
| `/kyc pair` · `pair off` | Turn pair mode on or off |
| `/kyc off` | Skip the gate once (logged) |

### Other agents

The quiz is an [Agent Skill](https://agentskills.io) (`skills/know-your-code/SKILL.md`), so any agent that reads skills can run it. The gate is a hook, so it only works where the agent has hooks.

| Agent | Gate (blocks push) | Quiz skill | Teaching workflow / reminder | Status |
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

Claude Code's Learning output style can mark gaps with `TODO(human)`, but it does not provide this repository-specific understand → build → verify → transfer workflow or connect learning evidence to the shipping quiz. know-your-code complements it: use the style for useful handoffs, and use `/kyc pair` when you want explicit checkpoints.

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
