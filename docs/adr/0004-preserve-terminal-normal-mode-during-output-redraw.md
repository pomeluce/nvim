# Preserve Terminal normal mode during output redraw

## Decision

Terminal tab focus restoration is limited to the explicit open or tab-switch operation that requested it. Its pending timer exits as soon as the active terminal is in Terminal normal mode (`nt`), and terminal output redraws do not re-enter insert mode or move focus.

## Context

Interactive commands such as package updates and coding agents continuously rewrite terminal output. A floating terminal can redraw while the user is trying to inspect that output in Terminal normal mode. The existing delayed focus restoration treated every mode other than terminal insert mode as an unfinished open operation, so a pending callback could call `startinsert!` again and make movement appear to drift or be lost.

## Consequences

Opening a terminal and switching tabs still restore focus and enter terminal insert mode. Once the user enters Terminal normal mode, the pending restoration stops and the mode remains under user control while the job continues to write output. The implementation relies on the `nt` mode signal and does not add output callbacks or polling to the terminal redraw path.
