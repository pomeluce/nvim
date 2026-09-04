# Neovim Formatting Context

This glossary defines the project terms used when selecting and running formatters from Neovim.

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
