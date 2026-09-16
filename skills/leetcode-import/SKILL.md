---
name: leetcode-import
description: Scaffold a new LeetCode problem or contest question end-to-end from either a full pasted LeetCode page or a curated 4-piece input (number, title, examples, code stub) — runs scripts/new.sh or scripts/new-contest.sh, writes the correctly-typed class Solution stub, fills .in/.out test data from the examples, and wires run()'s parser to match. Use when the user pastes a LeetCode problem statement (with its number/title) or a contest question and asks to import/scaffold/set it up. Never fills in solve logic — only structure, matching this repo's Daily Loop of solving solo first.
---

# LeetCode Import

Turns LeetCode problem info into a fully-wired, ready-to-solve file in one pass: correct `class Solution` signature, `.in`/`.out` test fixtures from the examples, and a working `run()` parser — everything this session did by hand, over and over, for every single problem.

**Two accepted input shapes — detect which one you got before doing anything else:**

1. **Curated (preferred):** the user supplies exactly four things — problem number, title, the `Example N` blocks (for test data), and the Code tab's `class Solution { ... }` stub. This is the *recommended* shape to ask for when the user hasn't already pasted something: it has essentially none of the copy-paste-artifact risk described in Step 0 below, since there's no prose/constraints/UI-chrome blob to scrape noise out of. When this shape is detected (four clearly-labeled or clearly-separable pieces, no leftover Description prose), skip straight to Step 1 using the light-touch rules there — Step 0's heavier scanning doesn't apply.
2. **Full page paste:** the user dumps the raw Description tab (and ideally Code tab) text, unstructured. Apply Step 0's full scan before trusting any of it.

**Hard boundary — never violate this:** this skill scaffolds *structure only*. It must never write the actual algorithm/solve logic into the method body. Leave the body empty (matching whatever the generic-stub or shape-template convention already produces) so the user still solves it themselves, per this repo's README Daily Loop. Because no solution logic is written, **do not** add an `// ASSISTED:` tag for this skill's own work — that tag is reserved for when solve logic itself is supplied (established precedent all session: parser-only fixes never got tagged, only actual algorithm implementations did).

## Why external fetching isn't part of this

Tested directly: LeetCode's problem pages return `403 Forbidden` to unauthenticated fetches, and no reliable third-party mirror has both (a) the full statement/examples/signature and (b) coverage of recently-numbered problems. The one piece that must stay manual is the user supplying the problem's number/title, examples, and Code-tab stub — either as a raw full-page paste or as the curated 4-piece shape above. Everything after that is this skill's job.

## Invocation shapes

- **Numbered problem:** `/leetcode-import <problem-number> <pasted LeetCode page text>`, or the curated form: `/leetcode-import <problem-number> <title> <Example blocks> <code stub>` in any reasonable order/labeling.
- **Contest question:** `/leetcode-import contest <weekly|biweekly> <contest-number> <Q1|Q2|Q3|Q4> <pasted LeetCode page text>` (curated form works the same way — number/type/question-letter plus title, examples, code).

Detect which mode from the first token of `args` (`contest` literal vs. a bare number).

## Step 0 — Sanity-check the pasted text before trusting any of it

**Skip this whole step for the curated 4-piece input shape** (number, title, examples, code stub, nothing else) — go straight to Step 1. This step exists specifically to defend against React-SPA copy-paste artifacts in a *raw full-page dump*; a curated input has no such prose blob to scrape noise out of, so applying these checks to it just risks false positives (e.g. misreading a deliberately terse title as "truncated"). Only apply the following when the input looks like an unstructured page dump (long Description prose, difficulty/topics/constraints sections, etc. all present):

Copies off LeetCode's page are prone to real artifacts, not just user typos — it's a React SPA with duplicate hidden DOM nodes (for accessibility/SEO) and MathJax-rendered math, and it's easy to accidentally select sidebar chrome along with the real content. Before extracting anything in Step 1, scan for:

- **Duplicated paragraphs/examples** — the same sentence or `Example` block appearing twice, back-to-back or interleaved. Use only one copy; don't treat it as two different examples.
- **UI chrome bleeding in** — stray fragments like `Discuss`, `Editorial`, `Submissions`, `Premium`, `Companies`, `Copy`, `Run`, `Submit`, `Accepted`. These aren't part of the problem — strip them, don't try to parse them as content.
- **Raw LaTeX leftovers** — `\(`, `\)`, `\times`, `\leq`, `\dots` etc. instead of rendered math. Harmless to read past, but don't transcribe the backslash-escapes literally into a comment or title.
- **Internal inconsistency** — does every `Example` block have both an `Input:` and `Output:`? Does the number of examples you can find match what the text implies? Do variable names in the `Input:` lines match a pasted code block's parameter names, if one was included? A mismatch here is a strong signal something got mangled or truncated in the copy.

**If anything looks corrupted, duplicated, or inconsistent enough that you're not confident in what the real problem says: stop and ask the user to re-paste that specific part**, rather than guessing past it or silently proceeding with a best-effort interpretation of garbled input — a wrong signature or wrong test data scaffolded confidently is worse than pausing to ask once.

## Step 1 — Extract signature, title, and test cases

For the **curated shape**, this is nearly mechanical — number and title are given directly (no first-line parsing needed), and the code stub is always present, so:

- **Title / number:** take verbatim from what was given.
- **Method signature:** take directly from `class Solution { public: <returnType> <name>(<params>) {` — this is the *only* source needed in the curated shape (no constraints text is supplied to infer types from, but none is needed: the stub's types are already exact, e.g. LeetCode itself already picked `int` vs `long long` for the return type based on the real constraints).
- **Test cases:** every `Example N` block's `Input:`/`Output:` becomes one `.in`/`.out` pair — same extraction as below.

For a **full page paste** (no code block, or inferring despite one), apply judgment the same way you would if a user asked "fix parser" cold — there's no reliable regex for arbitrary LeetCode prose, this is inference, not parsing:

- **Title / number:** usually the first line, e.g. `3875. Construct Uniform Parity Array I`. If the number wasn't in the invocation args, take it from here.
- **Method signature:**
  - If the pasted text includes a C++ code block (the user copied the "Code" tab, not just "Description"), take the signature directly from `class Solution { public: <returnType> <name>(<params>) {` — highest confidence, use this whenever present.
  - Otherwise, infer it from the `Example`/`Input:`/`Output:` lines, exactly the way you've inferred parser shapes manually all session: each `varName = value` in an `Input:` line is one parameter — `[1,2,3]` → `vector<int>&`, `["a","b"]` → `vector<string>&`, `"abc"`/`'abc'` → `string`, a bare number → `int` (or `long long` if the problem statement's constraints clearly exceed 32-bit range), `true`/`false` → `bool`. The `Output:` line's shape gives the return type the same way. Derive a reasonable camelCase method name from the problem's imperative phrasing near "Return..." (e.g. "Return the number of..." → something like `countX`); this is a best-effort guess exactly like a human skimming the page would make, and it's trivially renamable afterward if wrong.

**Test cases (both shapes):** every `Example N` block's `Input:`/`Output:` becomes one `.in`/`.out` pair. Reformat each `Input:` line by splitting on top-level commas, stripping each `varName = ` prefix, and writing the remaining value on its own line — this matches the repo's established fixture convention (`README.md`'s "Test fixture convention" section) and is literally how every `.in` file in this repo already looks (e.g. `[3,6,9]` on one line, `3` on the next). Do the same strip for `Output:` (no prefix to strip there, just the value on its own line). Preserve LeetCode's own example order and count — don't invent or drop cases.

## Step 2 — Match a known shape, or fall back to hand-wiring

Compare the inferred signature against `scripts/new.sh`'s shape table (run `scripts/new.sh` with no args to print it, or read `problems/*/*.cpp` for examples — the table is also mirrored in `README.md`).

- **If it matches a known shape exactly:** scaffold and wire in one step:
  ```
  scripts/new.sh <n> "<Title>" <shape> <methodName> --tests <exampleCount>
  ```
  This produces a fully-wired `run()` already — skip straight to Step 4.
- **If it's bespoke** (e.g. a `ListNode*`/`TreeNode*` parameter, a mix of 3+ container types, anything not in the table): scaffold the generic stub instead, then hand-wire both files yourself, the same way you've done for every bespoke problem this session (e.g. `2058.cpp`'s `ListNode*`, `3568.cpp`'s `vector<string>&, int`):
  ```
  scripts/new.sh <n> "<Title>" --tests <exampleCount>
  ```
  This creates two files — `problems/<bucket>/<n>.cpp` (solution) and `tests/<bucket>/<n>/run.cpp` (harness). `Edit` **both**: in the solution file, replace `// TODO: implement` inside `class Solution` with the real signature (empty body); in the harness file, replace the generic `Parse::intVec` placeholders in `run()` with the correct parser. Add new helpers to `runner.h` if a genuinely new input shape appears (following the precedent of `quotedLine`/`strVecBracketed` added earlier this session) — don't add a `runner.h` helper for a one-off shape that won't recur.
  - If a `ListNode`/`TreeNode`-style structure is needed and isn't already defined, define the real `struct` (not a comment stub) in the **solution** file (it's part of the type the method signature uses), and build the structure from the parsed input inline in the **harness** file's solve lambda, matching `2058.cpp`'s pattern.

If the same bespoke shape shows up on a second occurrence, consider proposing to add it to `scripts/new.sh`'s table and `README.md` (matching the precedent set earlier this session) — but don't do this preemptively for a single one-off case.

## Step 3 — Fill test data

Write each parsed example into `tests/<bucket>/<n>/<k>.in` / `<k>.out` (created empty by `new.sh`). If the page has more or fewer examples than the default `--tests 3`, adjust: delete the extras, or create additional numbered pairs — don't leave stray empty placeholder files, and don't silently drop a real example either.

**Before writing any `.out` file, check the exact output parser the harness actually uses** — read the comment next to it (e.g. `// output: [1,2,3,...]` vs `// output: space-separated ints`) rather than assuming every vector-returning shape wants bracketed output. Most do (`vec`, `matrix`, `scalar-vec`, `str-query` all use `Parse::intVecBracketed`, matching the bracketed input convention) — but `vec-int`'s template is the one exception, using `Parse::intVec` (space-separated, unbracketed) for its vector output. Getting this wrong doesn't fail loudly: `Parse::intVec` silently parses a bracketed `[1,2,3]` line as zero ints (`[` isn't a valid int start), so the harness quietly compares the correct answer against an empty expected vector and reports a spurious mismatch instead of a parse error. This exact mistake happened on problem 1470's `.out` files — the solution was already correct, only the fixture format was wrong. (The same non-obvious-mismatch risk applies to string output too — see the `strVec` vs `quotedString` quoting note from problem 1678: `strVec` does not strip quotes, so a quoted `.out` value will silently fail to match an unquoted actual result.)

## Step 4 — Switch and sanity-check

- For a numbered problem: `scripts/new.sh` already switches `main.cpp` for you.
- For a contest question:
  1. If `contests/<Type>/<number>/` doesn't exist yet, create it non-interactively by piping answers into the interactive script (reuses its tested logic rather than duplicating it):
     ```
     printf '<1 for Weekly, 2 for Biweekly>\n<contest-number>\n4\n3\n' | scripts/new-contest.sh
     ```
  2. If it already exists, skip that — don't re-scaffold over existing sibling questions.
  3. Hand-wire the specific `Qn.cpp` (solution) and its `tests/Qn/run.cpp` (harness, generic stub or shape-matched, same two-file split as Step 2) and fill `tests/Qn/` fixtures (same as Step 3).
  4. Point `main.cpp` at the target question's **harness** file directly (writing the same template `switch.sh`/`switch-contest.sh` produce, since piping through `switch-contest.sh`'s two nested menus just to select a path you already know precisely isn't worth the fragility):
     ```cpp
     #include "runner.h"
     #include "contests/<Type>/<number>/tests/Q<n>/run.cpp"

     int main() { run(); return 0; }
     ```

- Then always: `rm -f build/CMakeFiles/LeetCode.dir/main.cpp.o && cmake --build build -j4`. For scalar/bool-returning shapes, confirm it compiles with **only** the expected `-Wreturn-type` warning (empty stub body) — falling off the end there is harmless UB (garbage `int`/`bool`, no crash). For any shape returning a heap-backed type — `vector`/`string`/`vector<vector<...>>` (`vec`, `vec-int`, `matrix`, `scalar-vec`, `scalar-matrix`, `str-query`, `str-scalar-str`, and any bespoke `string`/`vector`-returning stub you hand-wire) — the stub calls `abort()` instead of falling off the end. Falling off the end of a function returning one of these is UB that can manifest as a **hang** (a garbage `size()`/capacity field makes `reportResult`'s printer spin near-forever) rather than a clean crash — confirmed in practice for both `vector<int>` and `string` returns this session, not just a theoretical risk. Expect a **clean build with no warnings** for these, and a deterministic `SIGABRT` on run — that's the correct/expected outcome, not a bug. Any other warning/error, or a hang instead of a normal PASS/FAIL or `SIGABRT`, means the signature or parser wiring is actually broken and needs fixing before handing off.

## Step 5 — Report back

Summarize concisely: file(s) created (both the solution file and its `run.cpp` harness), method signature used (flag if inferred rather than taken from a pasted code block, since that's the lower-confidence path), number of test cases filled, and confirmation that it builds cleanly. Mention that `scripts/copy.sh <n>` is available whenever they're ready to paste the finished solution back to LeetCode — just a one-line pointer, don't run it now, since there's no solution to copy yet. Then stop — solving it is the user's next step, not this skill's.
