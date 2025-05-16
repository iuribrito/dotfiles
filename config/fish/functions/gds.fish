function gds --wraps='git diff --staged' --description 'alias gds=git diff --staged'
    git diff $argv --staged
end
