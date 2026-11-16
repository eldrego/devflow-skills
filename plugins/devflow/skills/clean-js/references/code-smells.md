# Code smells

Heuristics for spotting design problems in changed code, based on Martin
Fowler's *Refactoring* (ch. 3), adapted to JavaScript/TypeScript and React.

## How to use this list

- **Smells are judgement calls, not violations.** Report them as
  "possible <smell>", never as errors. The rules in SKILL.md are firm; these
  are not.
- **The repo wins.** If the project's documented standards or existing patterns
  deliberately endorse something listed here, don't flag it.
- **Skip what tooling enforces.** If Biome, ESLint, or TypeScript already catches
  it, it's not a smell report.
- **Only flag what the change introduces or makes worse.** Pre-existing smells
  in untouched code are out of scope.
- **Not listed here on purpose:** long functions, long parameter lists, magic
  numbers, mutation, and nesting. Those are firm rules in SKILL.md.
- **Report format:** `possible <Smell> — file:line — what you saw — suggested fix`

## Contents

1. Naming and duplication: Mysterious Name, Duplicated Code
2. Responsibilities: Feature Envy, Divergent Change, Shotgun Surgery, Middle Man
3. Data: Data Clumps, Primitive Obsession, Repeated Switches
4. Abstraction: Speculative Generality, Message Chains, Refused Bequest
5. Frontend: Prop Drilling, God Component, Leaky Remote Boundary

---

## 1. Naming and duplication

**Mysterious Name**
- Looks like: `data`, `info`, `handle()`, `process()`, `temp`, `utils.ts`, or a
  name that no longer matches what the code does.
- Fix: rename to what it holds or does. If no honest name comes to mind, the
  function is probably doing too much.
- Don't flag: conventional short names in small scopes (`i`, `e` in handlers,
  `acc` in `reduce`).

**Duplicated Code**
- Looks like: the same logic appearing in two or more places in the change,
  such as copy-pasted fetch-and-map logic, or identical validation in two
  handlers.
- Fix: extract a shared function or hook and call it from both places.
- Don't flag: two occurrences that merely look alike but will change for
  different reasons. Wait for a third before abstracting.

## 2. Responsibilities

**Feature Envy**
- Looks like: a function that mostly reads another object's or module's data,
  e.g. a component computing `order.items`, `order.discount`, `order.tax` to
  get a total.
- Fix: move the logic next to the data, e.g. `getOrderTotal(order)` in the
  order module.

**Divergent Change**
- Looks like: one file edited in this change for several unrelated reasons
  (auth logic, styling, and analytics all in `app.tsx`).
- Fix: split it so each module changes for one reason.

**Shotgun Surgery**
- Looks like: one logical change forcing small edits across many files, such as
  adding a field that touches 8 files in the same way.
- Fix: gather what changes together into one module, or make it a single
  source of truth (a config, a schema, a contract).

**Middle Man**
- Looks like: a function, class, or hook that only passes calls through to
  something else and adds no logic.
- Fix: remove it and call the real target directly.
- Don't flag: deliberate boundaries such as API clients, adapters around
  third-party libraries, or a public module that hides internals.

## 3. Data

**Data Clumps**
- Looks like: the same group of values always travelling together, e.g.
  `(street, city, postcode)` or `(userId, token, expiresAt)`.
- Fix: give the group a type or object and pass that instead.

**Primitive Obsession**
- Looks like: plain strings or numbers standing in for domain concepts (status
  strings compared everywhere, prices as raw numbers with ad-hoc rounding, IDs
  of different entities that are all `string`).
- Fix: use a union type (`type Status = 'active' | 'pending'`), a small value
  object, or a branded type.

**Repeated Switches**
- Looks like: the same `switch` or `if` chain on the same value appearing in
  more than one place.
- Fix: a single lookup map or config object that every place uses.

## 4. Abstraction

**Speculative Generality**
- Looks like: options, generics, parameters, hooks, or abstraction layers added
  "for later" with only one real use, or for needs the plan doesn't mention.
- Fix: remove it and inline the logic. Add the abstraction when a real second
  use appears.

**Message Chains**
- Looks like: `state.session.user.profile.settings.theme` repeated across
  callers, so they depend on the whole structure.
- Fix: a selector or accessor (`selectTheme(state)`) so callers don't depend on
  the shape.

**Refused Bequest**
- Looks like: a class or implementation that overrides or ignores most of what
  it inherits or implements, e.g. interface methods that throw "not supported".
- Fix: drop the inheritance and use composition, or split the interface.

## 5. Frontend

**Prop Drilling**
- Looks like: props passed through 3 or more component levels that don't use
  them.
- Fix: context, a store (Zustand), or component composition (pass children).
- Don't flag: one or two levels. That's normal and explicit.

**God Component**
- Looks like: one component that fetches data, holds lots of state, contains
  business logic, and renders a large tree.
- Fix: extract custom hooks for the logic, and subcomponents for the parts of
  the UI.

**Leaky Remote Boundary** (microfrontends)
- Looks like: a remote importing another remote's or the shell's internal
  modules, depending on the internal shape of the shell's store, or reaching
  into another app's DOM or globals.
- Fix: communicate only through the shared contract (e.g. `contracts/`),
  exposed modules, or events.
