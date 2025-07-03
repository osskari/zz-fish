function zz
  set layouts_dir "$HOME/.config/zellij/layouts"
  set arg "$argv[1]"

  # helper to list layouts
  function _get_layouts
    if command -v fd > /dev/null 2>&1
      echo $(fd --max-depth 1 --extension kdl ".*" "$HOME/.config/zellij/layouts" | sed 's|.*/||; s/\.kdl$//')
    else
      echo "Warning: 'fd' not found, falling back to slower 'find'. Consider installing 'fd' for better performance." >&2
      echo $(find "$layouts_dir" -maxdepth 1 -name '*.kdl' -printf '%f\n' 2>/dev/null | sed 's/\.kdl$//')
    end
  end

  # --list option to print available layouts
  if test "$arg" = '--list'; or test "$arg" = '-l'
    echo 'Available Layouts:'
    _get_layouts
    return 0
  end

  # prevent nested zellij sessions
  if test -n "$ZELLIJ_PANE_ID"
    echo "You are already inside a Zellij session. Avoid nesting sessions."
    return 1
  end

  set session "$arg"

  # if no session try to use fzf
  if test -z $session
    if command -v fzf >/dev/null 2>&1
      set session $(_get_layouts | fzf --prompt="Select Zellij Layout > " --height=50% --layout=reverse --border --exit-0)

      if test -z $session
        echo "No layout selected."
        return 1
      end
    else
      echo "fzf not found and no layout argument given."
      echo "Available layouts:"
      _get_layouts
      return 1
    end
  end

  # verify layout exists
  if test ! -e "$layouts_dir/$session.kdl"
    echo "Layout '$session' does not exist in $layouts_dir"
    return 1
  end

  zellij list-sessions
  # attach or create session
  if zellij list-sessions | grep -E -q "$session.\["
    zellij attach "$session"
  else
    zellij -n "$session" -s "$session"
  end
end
