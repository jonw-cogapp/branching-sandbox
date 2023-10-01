# Branching sandbox

## Setup

Run the included shell (bash) script

```sh
bash ./setup.sh
```

This can be safely run repeatedly.

## Results

The current setup will conditionally delete, then create the branches:
- `develop-{suffix}` (orphans)
- `feature/custom-tours-{suffix}` (from `develop-{suffix}`)
- `pivotal-{suffix}-{n}` (from `feature/custom-tours-{suffix}`)

Where `suffix` is either "merge" or "rebase" and `n` is numbers 1-5. Each branch will have 5 empty commits.

The "merge" branches show the result of using merge from the pivotal branches down to develop

The "rebase" branches show the result when rebase is used on the pivotal branches to rebase these commits onto `feature/custom-tours-rebase`

Use a visual git tool to inspect the results. The results may be easier to inspect if you select only the "rebase" or "merge" branches.

