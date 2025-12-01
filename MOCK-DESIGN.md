# Mock Design

## Purpose

This document evaluates whether the system described in `PROBLEM.md`, `TECHNICAL.md`, and `VISION.md` is conceptually viable, what major architectural concerns exist, and what decisions need to be resolved before deeper implementation work begins.

It intentionally stays high level. The goal is not to lock in exact schemas, file formats, or low-level implementation details. The goal is to define a realistic architectural direction for a composable Hugo-based orchestration system built from a lightweight theme layer and self-integrating micro-modules.

## Executive Assessment

The proposed system is fundamentally implementable, but only if the design is framed as a convention-driven orchestration model rather than a literal runtime dependency injection container.

Hugo can support the core shape of the idea:

- a top-level site that imports an orchestration layer and feature modules
- modules that ship templates, assets, translations, and configuration defaults
- a theme or module that exposes extension points and reconciles module contributions
- a build process that aggregates declarative registrations and renders them into stable hook surfaces

The main caveat is that Hugo does not natively provide a general plugin runtime, event bus, or automatic discovery/execution model for arbitrary template behavior. "Self-registering" is realistic only when backed by an explicit contract for how modules declare their contributions and how the orchestration layer discovers them.

In short:

- Yes, the system is viable.
- No, it will not work well as pure magic.
- It needs a deliberate registration contract, deterministic ordering rules, and clear boundaries around what modules may contribute.

## What The Source Documents Clearly Establish

The three source documents are strongly aligned on the following principles:

- The website layer should remain simple and mostly configure through Hugo config, `data/`, and `content/`.
- The theme layer should act as orchestration infrastructure, not as a feature-heavy monolith.
- Functionality should live in narrow, isolated micro-modules.
- Modules should self-integrate into shared rendering pipelines with minimal manual wiring.
- Rendering should be compositional, with multiple modules participating in shared extension surfaces.

There is also a clear philosophical direction:

- composition over customization
- registration over hardcoded integration
- reusable extension points over direct theme edits
- isolated modules over centralized feature ownership

That direction is coherent. The missing pieces are not about intent; they are about the operational contract.

## Feasibility Boundary In Hugo

The core idea fits Hugo, but only in a specific way.

Hugo's module and theme-component system already provides the underlying composition model:

- modules and theme components can be imported and layered
- `data` and `i18n` contributions are deeply merged
- `assets` can be mounted into Hugo's unified file system and discovered as global resources
- templates and static files are merged by precedence, not by additive composition

This leads to an important design constraint:

Modules should not rely on generic discovery of arbitrary layout files as the registration mechanism. Layouts collide by path precedence, and Hugo does not naturally treat them as an additive registry.

Instead, the self-registration mechanism should live in a part of Hugo's unified file system that is naturally aggregatable, such as:

- namespaced data contributions
- discoverable global resources
- module configuration that feeds a common registry contract

The orchestration theme should then render those registrations through explicit extension points.

This is the difference between a viable Hugo architecture and an overly magical one.

## Proposed Conceptual Architecture

### 1. Website Layer

The website is the consuming application.

Its responsibilities should stay narrow:

- import the orchestration theme and desired micro-modules
- provide site content
- provide site-specific configuration and data
- enable, disable, or tune modules
- optionally override selected extension-point behavior

The website should not be responsible for manually stitching module templates together during normal use.

### 2. Orchestration Theme Layer

The orchestration theme is the framework kernel.

Its responsibilities are:

- define the stable extension surfaces
- discover module registrations
- normalize and reconcile contributions
- apply enablement rules
- determine rendering order
- render contributions into the correct places
- provide debugging and observability for active modules and resolved hooks

The orchestration theme should contain as little feature-specific behavior as possible. Its job is to coordinate, not to own domain logic.

### 3. Micro-Module Layer

Each micro-module is an isolated capability package.

A module may provide some combination of:

- templates or renderer partials
- CSS or JavaScript assets
- static files
- translation resources
- configuration defaults
- registration metadata

Each module should own its own feature logic and integration behavior within the boundaries of the shared orchestration contract.

## Recommended Composition Model

### Module Contract

Each module should declare its participation through a small declarative registration artifact. The exact serialization can remain undecided for now, but conceptually it should express:

- module identity
- the capability or capabilities it provides
- which extension points it contributes to
- where its renderer or assets live
- optional activation conditions
- optional ordering hints
- optional dependencies on other capabilities or shared surfaces

This contract is the real heart of "self-registration."

Without it, the theme has no reliable, generic way to discover what a module intends to do.

### Extension Surfaces

The orchestration theme should expose a modest initial set of shared extension points. A good early set would include:

- page head
- page footer
- metadata
- navigation contribution
- asset contribution
- localization contribution

The design should resist creating an open-ended hook taxonomy too early. Too many surfaces will make the system hard to reason about and hard to stabilize.

### Contribution Types

Not every contribution should be treated the same way. At a high level, the system should distinguish between:

- render contributions
- asset contributions
- metadata contributions
- navigation or menu contributions
- localization contributions
- behavior modifiers that affect how another surface is rendered

This does not require a full schema today, but it does require a conceptual distinction. A script tag, a menu item, and a metadata block should not be treated as identical payloads.

### Discovery And Resolution Flow

The intended build-time flow should look like this:

```text
Website config/content/data
        |
        v
Imports orchestration theme + micro-modules
        |
        v
Hugo unified file system merges module assets/data/i18n/layouts
        |
        v
Orchestration theme discovers registration artifacts
        |
        v
Theme resolves enablement, ordering, conflicts, and context
        |
        v
Theme renders contributions into extension surfaces
        |
        v
Static site output
```

That is the highest-value architectural pattern to preserve.

## What Is Realistically Easy Versus Hard

### Relatively Straightforward

- additive contributions to shared hook points like `head` and `footer`
- aggregation of module-owned assets
- merged localization resources
- site-level configuration of which modules are enabled
- simple metadata participation

### Moderately Complex But Viable

- deterministic ordering across many modules
- conditional activation by page kind, section, language, or environment
- menu contribution and reconciliation
- page-aware rendering decisions inside shared hook points
- asset de-duplication and bundling policies

### High-Risk Or Easy To Over-Promise

- fully generic "arbitrary extension hooks" without a stable contract
- zero-contract auto-discovery of behavior from layouts alone
- modules that deeply rewrite the same structural page areas without collisions
- complex inter-module dependencies that start to resemble a plugin runtime
- emergent behavior that becomes impossible to debug

This is where the system can drift from elegant composition into hidden coupling.

## Critical Architectural Constraints

### 1. Self-Registration Must Be Contractual

The phrase "self-registering" should not mean "the theme somehow figures everything out automatically." It should mean:

- every module follows a known contribution contract
- the orchestrator knows where to look for registrations
- renderers and assets are referenced through conventions

If this contract is weak, the architecture will become brittle very quickly.

### 2. Namespacing Is Mandatory

Because Hugo merges `data` and `i18n` and resolves layouts by path precedence, namespacing is not optional.

Modules need namespaced ownership of:

- registration identifiers
- data roots
- translation keys
- renderer paths
- asset identities

Without this, collisions will be frequent and difficult to diagnose.

### 3. Ordering Must Be Deterministic

Once multiple modules can contribute to the same surface, the system needs stable ordering rules.

Possible high-level ordering inputs include:

- module import precedence
- explicit weight or priority hints
- before/after relationships
- orchestrator-defined defaults

The exact policy can be decided later, but the system cannot defer this problem forever.

### 4. The Theme Must Own The Hook Vocabulary

Micro-modules should not invent arbitrary global surfaces without the orchestration layer understanding them.

The theme must define:

- what extension points exist
- what kinds of contributions each accepts
- when in the rendering process they are evaluated
- what context is available to module renderers

Otherwise the system will lose coherence.

### 5. Debuggability Is A First-Class Need

This architecture will be difficult to trust if users cannot answer:

- which modules are active
- why a contribution rendered
- what order contributions were resolved in
- why a contribution was skipped
- where a given asset or metadata fragment came from

A debug or trace mode should be considered part of the framework, not an afterthought.

## Major Ambiguities And Unresolved Decisions

The current documents leave several important questions unanswered.

### Registration Source

Where does the canonical registration artifact live?

This is likely the most important unresolved decision in the whole design. The system needs a discovery mechanism that is additive, predictable, and easy for module authors to follow.

### Activation Model

Can modules be:

- always on when installed
- enabled by config
- conditionally active by page type
- conditionally active by language
- conditionally active by environment

This affects both the registration contract and the user experience.

### Contribution Granularity

Should modules contribute:

- final rendered output
- structured intent that the theme renders
- both, depending on the hook type

This is a strategic choice. Structured intent gives the orchestrator more control. Raw renderer ownership gives modules more autonomy.

### Cross-Module Dependencies

Can one module depend on:

- another named module
- a capability rather than a specific module
- shared utilities from the orchestration theme only

This decision will strongly affect system complexity.

### Override And Escape Hatches

How can a website:

- replace a module renderer
- suppress a module contribution
- reorder modules locally
- override default assets or translations

If the system does not define safe escape hatches, users will fall back to direct template surgery.

### Scope Of "Arbitrary Extension Hooks"

Do arbitrary hooks mean:

- a small expandable registry of well-known surfaces
- user-defined custom surfaces
- fully open-ended hook names invented by modules

The last option is powerful but risky. It shifts complexity from the framework core into debugging and governance.

## Clarifying Questions

These do not block a mock design, but they should be answered before implementation solidifies:

1. Is the first release expected to support only additive composition, or also structural replacement of major page areas?
2. Should modules register structured contributions, module-owned renderers, or a hybrid of both?
3. Is module ordering meant to be mostly implicit, or is explicit site-level control expected?
4. Are module dependencies allowed, and if so should they target specific modules or abstract capabilities?
5. Is localization contribution limited to translation strings, or should modules also influence locale-aware rendering and asset selection?
6. Does the website need per-page or per-section module activation, or is site-wide enablement enough for the first milestone?
7. Should the orchestration theme expose user-defined custom hook names, or only a controlled set of framework-defined surfaces?
8. Is there an expectation that third-party modules can be safely composed without a central review process, or is this primarily a curated ecosystem?

## High-Level Repository Shape

One plausible repository direction is:

```text
/docs/                       conceptual and design documentation
/orchestrator/               the core orchestration theme/module
/modules/                    example or first-party micro-modules
/exampleSite/                integration playground and reference consumer
/tests/                      integration and regression coverage
```

Within that structure:

- `orchestrator` owns hook surfaces, resolution logic, and diagnostics
- each entry in `modules` demonstrates the expected module contract
- `exampleSite` proves the "install, configure, done" workflow
- `tests` focus on composition behavior, not only rendering snapshots

This is only a conceptual layout, but it would support the intended direction well.

## Recommended First Implementation Milestone

The first proof of concept should stay intentionally narrow.

A good milestone would validate:

- one registration mechanism
- two or three extension points
- two simple modules contributing simultaneously
- deterministic ordering
- configuration-based enable/disable behavior
- one debug view or trace output showing resolved contributions

A concrete example set could be:

- one analytics-style head injector
- one footer contributor
- one metadata contributor

If those compose cleanly, the architecture is likely on the right path. If they require ad hoc exceptions, the contract needs revision before expanding further.

## Overall Recommendation

Proceed with the architecture, but narrow the promise.

The strongest version of this system is:

- a Hugo orchestration framework
- built on modules and theme composition
- powered by declarative contribution registration
- centered on stable extension surfaces
- disciplined about namespacing, ordering, and observability

The weakest version would be an attempt to simulate a fully dynamic plugin runtime inside Hugo templates. That path is likely to create fragility, hidden coupling, and poor debuggability.

If the project defines a strong registration contract early, the vision is credible and technically coherent.

## Reference Notes

The feasibility assessment above is consistent with current Hugo documentation on:

- theme components and precedence
- module mounts and unified file system behavior
- deep merging of `data` and `i18n`
- discovery of mounted global resources from `assets`
- dependency inspection via `hugo.Deps`
