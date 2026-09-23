---
name: leetcode-add-test
description: Add one new test case (<id>.in / <id>.out) to an existing problem in the ~/Documents/leetcode C++ harness repo. Asks for the problem number (if not given), then asks the test id, every input parameter of the Solution method by name, and the expected output together in one multiple-choice question form (suggested answers + "Other" to type a value) — and writes both files in exactly the format that problem's run.cpp parsers expect. Use when the user says "add a test", "add test case", "new test for <n>", "add in/out file", "add a failing case from LeetCode", or invokes /leetcode-add-test [problem-number].
---

# LeetCode Add Test

Adds a single `<id>.in` / `<id>.out` pair to `tests/<bucket>/<n>/` in the `~/Documents/leetcode` repo. The user answers a short question form instead of hand-formatting files. Companion to `leetcode-import` (which scaffolds a whole problem); this skill only appends test data to a problem that already exists.

**Hard boundary:** only ever write `.in`/`.out` files. Never edit the solution file, `run.cpp`, or `runner.h`, and never compute the expected output yourself — the user supplies it (usually from LeetCode's "Expected" panel or an example).

**How to ask:** always use the `AskUserQuestion` tool, never plain chat questions. Each question gets 2–3 suggested options; the tool adds an "Other" choice automatically, which is where the user types their own value. Never add an "Other"/"Custom" option yourself.

## Step 1 — Problem number

If `args` starts with a number, use it and go to Step 2 without asking.

Otherwise ask one `AskUserQuestion` question (header `Problem`):

- option 1: the problem `main.cpp` currently includes (`tests/<bucket>/<n>/run.cpp`), label `<n>`, description `<Title> — active in main.cpp`
- option 2: the most recently modified `problems/*/*.cpp` if it's a different problem, same label/description style
- "Other" (automatic): user types any number

If only one candidate exists, use it plus the second most recently modified problem.

Resolve the bucket: `floor(n / 1000) * 1000` → `<lo>-<lo+999>` (e.g. `1470` → `1000-1999`, `42` → `0-999`). Paths:

- solution: `problems/<bucket>/<n>.cpp`
- harness: `tests/<bucket>/<n>/run.cpp`
- fixtures: `tests/<bucket>/<n>/<id>.in` / `<id>.out`

If the harness doesn't exist, stop and tell the user to scaffold the problem first with `leetcode-import` (or `scripts/new.sh`). If the solution or harness contains merge-conflict markers (`<<<<<<<`), stop and point them out — the parser to target is ambiguous until they're resolved.

## Step 2 — Read the problem before asking anything else

Read, in this order:

1. **Solution file** — the method signature inside `class Solution`: parameter names, types, return type. Note whether the body is still an `abort()` / `// TODO` stub.
2. **`run.cpp`** — the source of truth for file format, not LeetCode's display format:
   - The **input** lambda/parser: which `Parse::*` call (or `in >> x`) reads each parameter, and in what order. Line order in `.in` = the order the harness reads them, normally the signature order — if they differ, follow the harness.
   - The **output** parser (second argument to `runTests`) and its `// output:` comment.
   - Any transform in the solve lambda (e.g. a `ListNode*` built from a bracketed int list) — the user still types the LeetCode form (`[1,2,3]`).
   - If the input parser is still the generic `// TODO` placeholder from `new.sh`, stop: the harness isn't wired yet, so there's no format to match. Suggest `leetcode-import` to fix it.
3. **Existing fixtures** in the same test dir — collect every test id, and read `1.in`/`1.out` (or the lowest id) to mirror their exact style (spacing inside brackets, quote style, one field per line).

## Step 3 — Ask everything in one form

Build a single `AskUserQuestion` call with these questions, in this order:

1. **Test id** (header `Test id`)
2. **One question per input parameter**, in harness read order (header = parameter name, truncated to 12 chars)
3. **Expected output** (header `Output`)

`AskUserQuestion` allows at most 4 questions per call. If there are more than 4 (i.e. 3+ parameters), split into two calls: the first has the test id and as many parameters as fit, the second has the remaining parameters and the output. Never ask one question per message.

### Test id question

`Test id for <n> <Title>? Existing: 1, 2, 3`

- option 1: next free id (max + 1), label `<id> (Recommended)`, description `Next free id`
- option 2: if `new.sh` left an empty placeholder pair, that id (`Fill empty placeholder`); otherwise max + 2
- "Other": any positive integer — ids like `775` (LeetCode's failing-testcase number) are normal in this repo

### Parameter questions

`<name> (<type>) = ?` — e.g. `nums (vector<int>&) = ?`

Offer 2 suggested values that are genuinely useful as a new test, so the user can click instead of type:

- a boundary/edge case that fits the type and the constraints evident from the problem (single element, all-equal values, negatives, zero, max-length string, etc.), with a description saying what it covers (`Edge: single element`)
- the value from an existing fixture, labeled `Same as test <k>`, with the value in the description — useful when only one parameter changes between tests
- for `bool` parameters: just `true` / `false`

Labels must stay short (1–5 words): put long values in the description, not the label. If a parameter depends on another (e.g. `n == nums.length / 2`), say so in the question text so the user's picks stay consistent.

The user may paste a whole LeetCode `Input:` line (`nums = [2,7,11,15], target = 9`) into any "Other" box. Accept it: split on top-level commas (not commas inside `[...]` or quotes), strip the `name = ` prefixes, match values to parameters by name, and use those values for every parameter it covers.

### Output question

`Expected output (<return type>)? Paste LeetCode's "Expected" value in Other.`

Suggested options — never an answer you computed:

- `bool` return: `true` / `false`
- anything else:
  - `Skip .out for now` — writes only the `.in`; the runner prints `[SKIP] ... missing .out` until it's added
  - `Use my solution's output` — only offer this when the solution is not a stub; description: `Records what your current solution returns. Only use if it's already Accepted.` If the solution is a stub, offer `Same as test <k>` (value in the description) instead.

## Step 4 — Normalize answers

Convert every answer ("Other" text or picked option) to what its parser expects. If the user typed a format the parser can't read (e.g. `[1,2]` for a `Parse::intVec` field), convert it silently — that conversion is the point of this skill.

**Inputs:**

| Parser reading it | Write as | Example |
|---|---|---|
| `Parse::intVecBracketed`, `boolVecBracketed` | bracketed on one line | `[2,7,11,15]` |
| `Parse::int2DVecBracketed` | nested brackets on one line | `[[1,2],[3,4]]` |
| `Parse::strVecBracketed` | bracketed quoted strings on one line | `["S.","XL"]` |
| `Parse::intVec`, `boolVec`, `strVec` | space-separated, no brackets/commas | `2 7 11 15` |
| `Parse::int2DVec` | one row per line, space-separated | `1 2` ⏎ `3 4` |
| `Parse::quotedString`, `quotedLine` | quoted string on one line | `"abc"` |
| `in >> x` (int / long long) | plain number | `9` |
| `in >> s` (string, unquoted read) | as in sibling fixtures | `abc` |

Arrays always go alone on their own line (the bracketed parsers consume the whole line).

**Output** — follow the output parser, not LeetCode's display. This is the most common silent-failure spot:

- `Parse::intVec` with comment `single int` → plain number: `3`
- `Parse::intVec` with comment `space-separated ints` → `[0,1]` becomes `0 1` (problems 1 and 1470 do this)
- `Parse::intVecBracketed` / `int2DVecBracketed` → keep brackets: `[2,2,2]`, `[[9,9],[8,6]]`
- `Parse::boolVec` / bool comments → `true` or `false`
- `Parse::strVec` for a string return → **unquoted** (`Goal`): `strVec` does not strip quotes, so a quoted value silently mismatches
- `Parse::quotedLine` / `quotedString` for a string return → quoted is fine (`"Goal"`)
- `Parse::strVecBracketed` → `["e","l","l"]`

A wrong format doesn't error — the parser reads zero values and the case reports a confusing FAIL.

**Follow-up only when needed** — one more `AskUserQuestion` call, only for these cases:

- The chosen id already has non-empty `.in`/`.out`: show the current contents in the question and offer `Overwrite` / `Use next free id (<id>)`.
- An answer doesn't fit its type (e.g. `abc` for an `int`) or is ambiguous: re-ask just that question with the same option style.

## Step 5 — Write the files

Write `tests/<bucket>/<n>/<id>.in` and `<id>.out`:

- one field per line, LF line endings, exactly one trailing newline, no trailing spaces, no blank lines
- style matching the sibling fixtures from Step 2
- `Skip .out for now` → write only `.in`
- `Use my solution's output` → write `.in`, then switch `main.cpp` only if it already points at this problem (otherwise say you'd need to run `scripts/switch.sh <n>` and ask before switching), build and run, and copy the new case's `actual =` value into `.out` (it passes by construction; say so)

Don't touch any other file.

## Step 6 — Verify and report

- Show both files' contents.
- If `main.cpp` already includes this problem's `run.cpp` and the solution isn't a stub, run `cmake --build build && ./build/LeetCode` and confirm the new case appears (PASS or FAIL both prove it parsed; a FAIL where `expected =` prints empty `[]` means the format is wrong — fix it).
- If a different problem is active, don't switch `main.cpp`; just mention `scripts/switch.sh <n> && cmake --build build && ./build/LeetCode`.

Then ask with `AskUserQuestion` (header `Next`): `Add another test for <n>` / `Done`. If another, loop back to Step 3 — the problem is already known and the files are already read.
