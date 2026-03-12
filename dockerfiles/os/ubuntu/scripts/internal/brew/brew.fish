# brew
set -l BREW_PATH /home/linuxbrew/.linuxbrew/bin/brew
if test -x $BREW_PATH
    eval ($BREW_PATH shellenv)
    set -gx HOMEBREW_FORCE_VENDOR_RUBY 1
    set -gx HOMEBREW_NO_ANALYTICS 1
    set -gx HOMEBREW_NO_AUTO_UPDATE 1
end
