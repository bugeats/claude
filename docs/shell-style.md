# Shell Style

**`writeShellApplication` discipline**: `bootstrap.sh` runs under `set -o errexit nounset pipefail`. Shellcheck disable directives must sit above a complete compound command (not on an `elif`); factor out a helper if needed. Guard `&&` chains in functions with `if` statements — a short-circuiting chain as the last statement in a `for` loop inside a function propagates non-zero to the call site.
