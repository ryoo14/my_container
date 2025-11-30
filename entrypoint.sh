#!/bin/bash -l

# When ENTRYPOINT ["vim"] is used, vim launches directly without going through bash,
# which means .bashrc is not loaded and PATH environment variable doesn't include
# nvm or deno bin directories, causing LSP server installation and startup to fail.
# Therefore, I use exec to launch vim through bash to ensure .bashrc is loaded
# and proper PATH is set.
exec vim "$@"
