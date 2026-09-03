# Production Lessons Learned

Living record of production incidents and the operating rules derived from them. This file is not a substitute for `GAME1_RULES.md`; when a lesson becomes a mandatory production rule, promote the concise rule there and keep the incident rationale here.

## 1. Activity is not delivery

**Incident:** multiple orchestration passes produced plans, comments and governance churn while the playable result barely changed.

**Lesson:** when executable, visual or gameplay work is pending, a worker run must produce a concrete delta: code, asset, test improvement, CI evidence or gameplay capture. Documentation-only progress is not delivery.

**Supervisor action:** after one non-productive run, issue a concrete correction. After two repetitions of the same blocker, intervene directly when the action is reversible and the root cause is known.

## 2. Canonical identity is the workstream branch, not a historical PR number

**Incident:** merged or superseded PRs created confusion about which surface was active.

**Lesson:** one domain has one canonical branch and at most one active implementation/remediation PR. A merged PR becomes historical; it is not an excuse to create parallel workstreams.

## 3. Repointing is containment, not cleanup

**Incident:** stale branches were sometimes pointed at a canonical SHA instead of being removed.

**Lesson:** a stale ref remains cleanup debt until physically deleted. Repointing may temporarily contain risk only when deletion tooling is unavailable.

## 4. Merged does not mean accepted

**Incident:** MAP and PLAYER work was merged before technical, gameplay and visual acceptance were all satisfied.

**Lesson:** merge state and acceptance state are separate. Premature merges create remediation debt and must not silently lower the quality bar.

## 5. Gates are independent

A domain is accepted only when applicable gates all pass:

- technical: import/build, smoke, tests, lint/format;
- gameplay: movement, collision, navigation, interaction and intended loop;
- visual: real 1280x720 evidence reviewed against the quality target.

Tests alone never prove commercial visual quality.

## 6. Pixel art is a production pipeline, not a file-generation step

Required flow:

`art direction -> concept/base -> pixel cleanup -> asset-system assembly -> Godot integration -> 1280x720 capture -> critique/revision`

Generated images, procedural sprites and concepts are source material only until cleaned, assembled, integrated and reviewed in-game.

## 7. A repeated binary-asset failure requires direct intervention

**Incident:** `player_actions_64x96.png` repeatedly blocked PLAYER because the committed file was not a valid PNG. Multiple worker instructions repeated the same request without breaking the loop.

**Root cause evidence:** Godot reported `Not a PNG file` / `ERR_FILE_CORRUPT`, causing `player_visual.gd` preload failure and cascading animation/test failures.

**Lesson:** after the same confirmed binary blocker survives two worker passes, the supervisor should remove/revert the bad artifact when safe and force clean regeneration from source rather than continuing to ask for the same repair.

**Validation before commit:** verify file signature/magic bytes, decode with an independent image library/tool, then run the engine importer. An extension such as `.png` is not evidence that the file is valid.

## 8. Fix root causes, not cascades

**Incident:** one corrupt atlas produced parse errors, null visual state, missing locomotion calls and dozens of failing animation tests.

**Lesson:** identify the earliest failing component and repair it first. Do not patch downstream null checks or weaken tests to hide an upstream asset/import failure.

## 9. Reversible, root-cause-proven actions should not wait for approval

The supervisor should act directly when all are true:

1. root cause is demonstrated by evidence;
2. the action is reversible through Git/history;
3. no unique valuable work is destroyed;
4. the change stays within the canonical workstream.

Examples: remove a corrupt generated asset, revert a clearly defective commit, correct branch drift, close a superseded PR, or restore a required CI gate.

Ask the user before irreversible design choices, destructive loss of unique work, major scope changes or material architectural risk.

## 10. Do not fabricate evidence to make progress look better

**Incident:** a temporary integrated gameplay capture was requested while current PLAYER could not load. Falling back to an older character would have produced a misleading image.

**Lesson:** evidence must represent the actual state being claimed. A fallback, placeholder or older asset must be labeled explicitly and cannot count as acceptance evidence for the latest work.

## 11. Temporary integration is useful, but it is not acceptance

MAP and PLAYER heads may be combined in a throwaway/local integration state to discover cross-domain problems before merge. Such a state must not create a new canonical branch/PR and must not be presented as accepted production state.

## 12. Benchmark quality, never protected content

Graveyard Keeper is a benchmark for polish, cohesion, readability, composition, animation quality, feedback and loop density. Do not copy its sprites, maps, characters, names, narrative, layouts or assets.

The useful comparison question is: **does game1 still look like a technical prototype beside the benchmark?** If yes, the visual gate fails regardless of CI status.

## 13. Prefer one excellent compact zone over broad mediocre coverage

**Incident:** repeated MAP passes expanded or algorithmically adjusted terrain while grid repetition remained visible.

**Lesson:** when visual quality is below target, stop expanding. Author one compact zone to a high standard first: transitions, irregular paths, prop clusters, depth, occlusion and a clear landmark. Scale only after the visual language works.

## 14. Preserve a green technical baseline during visual polish

Once a domain is technically green, visual workers should avoid unrelated system changes. Art/composition passes must preserve the green baseline unless a visual requirement genuinely needs code support.

## 15. Slack is visibility; GitHub is source of truth

Slack can surface status, blockers and review outcomes, but canonical state lives in GitHub branches, commits, PRs, CI and repository documentation. Do not let Slack become a second governance database.

## 16. Evidence links must be usable by the intended reviewer

Internal or ephemeral environment paths are not durable project evidence. Prefer GitHub Actions artifacts, PR attachments or repository-hosted evidence when a human needs to reopen it later.

## 17. Documentation structure should expose authority

Root documentation should remain small and operational. Long-form architecture, art, design, narrative and localization documents belong under `docs/`, with `docs/README.md` as an index. Moving docs requires updating consumers atomically so agent prompts do not silently break.

## 18. Governance exists to accelerate production

If governance work repeatedly consumes runs without improving code, assets, CI or gameplay, it has become the bottleneck. Stop expanding governance and return to the playable critical path.
