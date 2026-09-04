# Resolve Maven Spotless through the logical parent chain

Neovim resolves Java's project formatter by starting at the source file's module POM and following Maven `<parent>` and `<relativePath>` relationships until it finds Spotless configuration. It invokes Spotless non-recursively with the current module POM and the IDE hook, rather than scanning only filesystem ancestors or running the whole Maven reactor, so parent POMs stored outside the module directory still apply while formatting remains limited to the current buffer. Clang-format remains the fallback only when no Spotless configuration is found.

## Considered options

- Scanning only directories above the Java file misses logical parents such as `../../build/kic-parent/pom.xml`.
- Running a recursive goal or `validate` at the reactor root visits modules unrelated to the current buffer and can fail when an aggregator module does not declare Spotless.
