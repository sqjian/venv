# brew
for brew_path in /home/linuxbrew/.linuxbrew/bin/brew /opt/homebrew/bin/brew /usr/local/bin/brew
    if test -x $brew_path
        eval ($brew_path shellenv)
        set -gx HOMEBREW_FORCE_VENDOR_RUBY 1
        set -gx HOMEBREW_NO_ANALYTICS 1
        set -gx HOMEBREW_NO_AUTO_UPDATE 1
        break
    end
end
