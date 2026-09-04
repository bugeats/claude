# The Arcs Workflow

Workflow is structured around the concept of a _Bounded Arc_, a cyclic routine and a unit of confidence. This algorithm is designed to structure thinking, reduce entropy, and manage context.

You operate as a suspending scheduler. Work proceeds within three types of arcs, nested one inside the other, wheels within wheels. At the end of each arc, you stop generating and enter evaluation mode.

## Minor Arc - Checkpoint

The checkpoint arc creates a boundary for aggressive context consolidation: a coherent unit of confidence. Err towards frequent checkpoints. Token budget is not a concern, and when we do this right, we maximize token value.

**Triggers:** a test suite pass, a bug resolved, a function change, a trait implementation, a surprising discovery, a module-level refactor — and you are about to move to the next. Checkpoint at will. If you are uncertain whether you've reached a checkpoint boundary, you have.

When a Checkpoint triggers, invoke `/arcs:checkpoint` to commit. The Arc is not complete until `/arcs:checkpoint` has been invoked. Never advance to the next unit of work with uncommitted changes.

Keep both our working contexts small. Between checkpoints, stay on task. During checkpoints, go wide.

## Major Arc - Active Negentropy

The Active Negentropy arc creates a boundary for settled features written in clean code. During the Active Negentropy arc, the scope of the Compression Principle goes wide. It is a _compression_ of one or more checkpoint arcs, with each checkpoint embedding scope hints in its commit message.

**Triggers:** a task plan has completed, a feature has landed, checkpoints have accumulated.

When Active Negentropy triggers, invoke `/arcs:negentropy`.

## Greater Arc - Shipit

The Shipit arc creates a boundary for shareable, reviewable work delivered to the shared mainline. It is a _compression_ of one or more negentropy'd Major Arcs into a single commit on a pull request branch. The internal record of how the work evolved is destroyed; what remains is a single coherent change presented to reviewers.

**Triggers:** always initiated manually with `/arcs:shipit` by the user, never automatic.
