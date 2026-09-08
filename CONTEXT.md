# Neovim Configuration Context

This glossary defines the project-specific language used for Neovim behavior and visual design.

## Visual theme

**Transparent canvas**:
The main editing surface, whose background is inherited from the host terminal.
_Avoid_: transparent theme, empty background.

**Elevated surface**:
A transient or interactive interface region distinguished from the transparent canvas by its border, title, and focused item while retaining the inherited background.
_Avoid_: popup background, opaque window.

**Functional accent**:
A color with a stable interface meaning, such as focus, information, warning, or error, rather than a decorative color chosen per component.
_Avoid_: component color, highlight color.

## Maven formatting

**Maven reactor root**:
The project directory that coordinates Maven modules and normally provides the Maven wrapper.
_Avoid_: module root, parent POM.

**Module POM**:
The `pom.xml` that belongs to the Maven module containing a source file.
_Avoid_: project POM, Spotless POM.

**Logical parent POM**:
A POM inherited through Maven's `<parent>` relationship, regardless of where it is located in the filesystem.
_Avoid_: directory parent, ancestor POM.

**Spotless configuration POM**:
A POM in a module's logical parent chain that declares the project's Spotless Maven integration.
_Avoid_: formatter POM, root POM.

**Formatter fallback**:
The formatter used when no project-specific Spotless configuration is available.
_Avoid_: backup formatter, default formatter.

## SQL formatting

**SQL dialect resolution**:
The selection of the SQL grammar that matches the current buffer, using explicit declarations before syntax evidence and a conservative ANSI fallback.
_Avoid_: dialect guessing, SQL detection.

**Buffer SQL dialect override**:
An explicit, temporary dialect selection attached to one open SQL buffer. It takes precedence over file and project declarations until the buffer is deleted or the override is cleared.
_Avoid_: SQL filetype, global dialect.

**Project SQLFluff configuration**:
A repository-owned definition of its SQL dialect and formatting conventions, which takes precedence over personal fallback conventions.
_Avoid_: local SQL config, formatter override.
