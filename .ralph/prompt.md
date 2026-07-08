# ISSUES

Local issue files from `issues/` are provided at start of context. Parse them to understand the open issues.
You will work on the AFK issues only, not the HITL ones.
You've also been passed a file containing the last few commits. Review these to understand what work has been done.
If all AFK tasks are complete, output <promise>NO MORE TASKS</promise>.

# TASK SELECTION

Pick the next task. Prioritize tasks in this order:
1. Critical bugfixes
2. Development infrastructure
3. Tracer bullets for new features
4. Polish and quick wins
5. Refactors

Getting development infrastructure like tests and types and dev scripts ready is an important precursor to building features.

TL;DR - build a tiny, end-to-end slice of the feature first, then expand it out.

## Progress Report Format

APPEND to progress.txt (never replace, always append):
<example>
```
## [Date/Time] - [Story ID]
- What was implemented
- Files changed
- **Learnings for future iterations:**
  - Patterns discovered (e.g., "this codebase uses X for Y")
  - Gotchas encountered (e.g., "don't forget to update Z when changing W")
  - Useful context (e.g., "the evaluation panel is in component X")
---
```
</example>

The learnings section is critical - it helps future iterations avoid repeating mistakes and understand the codebase better.

## Consolidate Patterns

If you discover a **reusable pattern** that future iterations should know, add it to the `## Codebase Patterns` section at the TOP of progress.txt (create it if it doesn't exist). This section should consolidate the most important learnings:

<example>
```
## Codebase Patterns
- Example: Use `sql<number>` template for aggregations
- Example: Always use `IF NOT EXISTS` for migrations
- Example: Export types from actions.ts for UI components
```
</example>

Only add patterns that are **general and reusable**, not story-specific details.

## Update CLAUDE.md Files

Before committing, check if any edited files have learnings worth preserving in nearby CLAUDE.md files:

1. **Identify directories with edited files** - Look at which directories you modified
2. **Check for existing CLAUDE.md** - Look for CLAUDE.md in those directories or parent directories
3. **Add valuable learnings** - If you discovered something future developers/agents should know:
   - API patterns or conventions specific to that module
   - Gotchas or non-obvious requirements
   - Dependencies between files
   - Testing approaches for that area
   - Configuration or environment requirements

**Examples of good CLAUDE.md additions:**
- "When modifying X, also update Y to keep them in sync"
- "This module uses pattern Z for all API calls"
- "Tests require the dev server running on PORT 3000"
- "Field names must match the template exactly"

**Do NOT add:**
- Story-specific implementation details
- Temporary debugging notes
- Information already in progress.txt

Only update CLAUDE.md if you have **genuinely reusable knowledge** that would help future work in that directory.

## Quality Requirements

- ALL commits must pass your project's quality checks (typecheck, lint, test)
- Do NOT commit broken code
- Keep changes focused and minimal
- Follow existing code patterns

# Code style

- **Mysterious Name** — a function, variable, or type whose name doesn't reveal what it does or holds. → rename it; if no honest name comes, the design's murky.
- **Duplicated Code** — the same logic shape appears in more than one hunk or file in the change. → extract the shared shape, call it from both.
- **Feature Envy** — a method that reaches into another object's data more than its own. → move the method onto the data it envies.
- **Data Clumps** — the same few fields or params keep travelling together (a type wanting to be born). → bundle them into one type, pass that.
- **Primitive Obsession** — a primitive or string standing in for a domain concept that deserves its own type. → give the concept its own small type.
- **Repeated Switches** — the same `switch`/`if`-cascade on the same type recurs across the change. → replace with polymorphism, or one map both sites share.
- **Shotgun Surgery** — one logical change forces scattered edits across many files in the diff. → gather what changes together into one module.
- **Divergent Change** — one file or module is edited for several unrelated reasons. → split so each module changes for one reason.
- **Speculative Generality** — abstraction, parameters, or hooks added for needs the spec doesn't have. → delete it; inline back until a real need shows.
- **Message Chains** — long `a.b().c().d()` navigation the caller shouldn't depend on. → hide the walk behind one method on the first object.
- **Middle Man** — a class or function that mostly just delegates onward. → cut it, call the real target direct.
- **Refused Bequest** — a subclass or implementer that ignores or overrides most of what it inherits. → drop the inheritance, use composition.

# IMPLEMENTATION

Use /tdd skill to complete the task.

# FEEDBACK LOOPS

Before committing, run the feedback loops:

- `make test` to run the tests
- `make typecheck` to run the type checker

# COMMIT

Make a git commit. The commit message must:

1. Include key decisions made
2. Include files changed
3. Blockers or notes for next iteration
4. Commits starts with prefix, docs: etc...
NEVER 'git add' or commit any file under issues/, docs/, or plans/ (they are read-only inputs); stage only code, tests.
NEVER commit log or ./ralph/progress.txt or meta-data ralph related.
DO NOT COMMIT BROKEN CODE
Append to ./ralph/progress.txt, never rewrite history.

# THE ISSUE

If the issue is complete, move the issue file to `issues/done/`.
If the issue is not complete, add a note to the issue file and don't move it to `issues/done/`.

# FINAL RULES

ONLY WORK ON A SINGLE TASK.
