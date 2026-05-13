# 过滤掉 dumb 终端
if test "$TERM" != "dumb"
    starship init fish | source
end
