# shellcheck disable=SC2148
# shellcheck disable=SC2155
git config --global core.quotepath false
git config --global core.autocrlf false
git config --global core.safecrlf true
git config --global --get user.email >/dev/null || git config --global user.email shengqi.jian@gmail.com
git config --global --get user.name >/dev/null || git config --global user.name sqjian
