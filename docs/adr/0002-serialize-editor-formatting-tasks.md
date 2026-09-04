# Serialize editor formatting tasks per buffer

Editor formatting is serialized per buffer because Maven Spotless starts a relatively expensive Maven process and Conform cancels an existing exclusive formatter when a new one starts. Automatic save formatting and the `:Format` command therefore skip a buffer that already has a formatting task in progress; the original task clears the state when it completes or fails.
