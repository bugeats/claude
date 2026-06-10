# Rust Style

In addition to the Universal Code Style, review the following Rust idioms.

- Borrow at boundaries: parameters take `&str`, `&[T]`, or `impl Trait`; structs store owned types.
- Newtype domain values. A bare `String` or `u64` crossing a module boundary is a missed type.
- `unwrap()`/`expect()` are test-only. Production paths propagate with `?` into a typed error.
- Iterator chains over index loops. Exhaustive `match` over boolean flag cascades.
- No code in `mod.rs` and `lib.rs` files. Decompose into modules anything that is not a simple module definition.
- Order definitions newspaper-style: type aliases and constants first (the file's vocabulary), then the important stuff at the top with details flowing downward — callers above callees, public above private, helpers at the bottom. Cluster blocks by kind.
- Use rustdoc comments lightly. Never add one whose information is redundant with what the code already expresses.
- Whenever possible, use `impl From` for type conversion. Methods like `to_other` and `from_other` should be avoided unless the conversion requires arguments.
- Use `impl Default` instead of `new()` for instantiation that does not need arguments.

## Tracing

For projects using the `tracing` crate:

- Use well crafted and nested spans to provide context instead of repeating fields.
- Keep messages short — two or three words, or none at all. Prefer fields over text.
- `impl std::fmt::Display` (fully qualified) for types that appear in spans and events. Construct a concise and human-readable string representation with no linebreaks.
- Messages use **imperative mood** — the verb form that reads as a command or action: `"start"`, `"skip write"`, `"promote to memory"`. Not past tense (`"started"`, `"skipped"`), not progressive (`"starting"`, `"skipping"`), not passive (`"was skipped"`).
