# Behavioral guidelines

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

Don't assume. Don't hide confusion. Surface tradeoffs.

Before implementing:

- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

Minimum code that solves the problem. Nothing speculative.

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.

## 3. Surgical Changes

Touch only what you must. Clean up only your own mess.

## 4. Skill Discipline

When the user expresses creation intent — "我要实现 / 我想做 / 帮我搭 / 帮我写 X", "let's build X", "add a feature that…" — invoke `Skill(brainstorming)` **before** asking clarifying questions or proposing options. Same for other process skills (debugging, TDD, etc.).

The "Simplicity First" and "trivial tasks" clauses govern code scope, not whether to invoke a skill — a skill check is procedural, not speculative work. Rationalizations to reject: "just a simple recommendation question", "AskUserQuestion is enough", "the skill feels heavy here".

## 5. Background Noisy & Long-Running Work

Run install scripts, builds, downloads, and other log-heavy or slow commands with `Bash(run_in_background: true)`.

- **Why:** foreground runs flood context with logs/errors — degrading later judgment — and block on work that could proceed in parallel.
- Background Bash is harness-tracked: completion re-invokes you. No polling, no foreground waiting.
- Backgrounding ≠ ignoring. Still check results and report the distilled outcome (what failed, why), not raw logs.
- This is the cheap fix. Spawning subagents is the heavier path — don't, unless asked.

## 6. Subagents for Exploration & Review

For exploration/investigation tasks and code-review tasks, dispatch a subagent instead of working in the main thread. This section is a standing "the user asked" — it overrides the default reluctance to spawn agents.

- **Exploration/investigation** — broad searches sweeping many files or directories: use the `Explore` subagent.
- **Code review** — use a review subagent (or the `requesting-code-review` skill).
- **Carve-out:** trivial cases stay in the main thread — a known single-file/single-symbol lookup ("where is X defined"), or reviewing a handful of lines. The test is §5's: if the output wouldn't pollute context anyway, don't pay a cold agent's start-up cost.
- **Why:** the subagent reads the file-dumps / verbose review in *its* context and returns only the conclusion — §5's isolation, taken one step further.
