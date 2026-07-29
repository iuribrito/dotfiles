set -U fish_greeting

if status is-interactive
    # Commands to run in interactive sessions can go here
end

starship init fish | source

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH


# pnpm
set -gx PNPM_HOME "/home/brito/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end
