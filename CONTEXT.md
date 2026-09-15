# Neovim Configuration Context

This glossary defines the project-specific language used for Neovim behavior and visual design.

## Plugin management

**Plugin inventory**:
The set of plugins selected for this configuration, including their repositories, version constraints, and enablement conditions.
_Avoid_: plugin configuration, load specification.

**Plugin configuration**:
The instructions for integrating an inventory plugin into the editor, including its dependencies, build steps, loading conditions, and editor behavior.
_Avoid_: plugin inventory, repository declaration.

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

**CREATE TABLE segment alignment**:
A fallback layout convention that aligns data types and ordinal constraint slots independently within each table definition. Constraint slots reflect syntax position rather than constraint meaning.
_Avoid_: semantic constraint columns, cross-table alignment.

**Compact clause layout**:
A fallback layout convention that keeps `COMMENT ON` statements atomic and places `FROM` with its first table expression while preserving all other clause and nested-query boundaries.
_Avoid_: single-line SQL, DataGrip layout.

**Project SQLFluff configuration**:
A repository-owned definition of its SQL dialect and formatting conventions, which takes precedence over personal fallback conventions.
_Avoid_: local SQL config, formatter override.

## Startup behavior

**Tool launch**:
An editor process explicitly started as a dedicated tool, without automatic project discovery or project-session restoration.
_Avoid_: standalone mode, dashboard mode.

## Database integration

**Database tool launch**:
A tool launch dedicated to database interaction.
_Avoid_: database session, CALLDB mode.

**Database query workspace**:
The persistent directory that holds interactive database query buffers across editor sessions.
_Avoid_: database path, connection directory.

## Java launching

**Main target**:
An executable Java Main class together with the project that owns it, before runtime details are resolved.
_Avoid_: debug configuration, loaded Main.

**Main discovery**:
The identification of available Main targets without resolving how any one of them will be launched.
_Avoid_: classpath scan, launch configuration loading.

**Launch preparation**:
The work performed after selecting a Main target to produce its current executable launch configuration.
_Avoid_: Main discovery, configuration preload.

**Launch runtime**:
The JDK used to run or debug a Main target, distinct from the JDK that hosts the language server.
_Avoid_: LSP runtime, default Java.

**Project-declared launch runtime**:
The launch runtime matching the Java version required by the active project context. It takes precedence over inferred or default runtimes.
_Avoid_: detected JDK, JDT runtime.
