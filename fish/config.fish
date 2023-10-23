if status is-interactive
    # Commands to run in interactive sessions can go here
end


# Zig
fish_add_path /opt/zig/

# OCaml
source ~/.opam/opam-init/init.fish > /dev/null 2> /dev/null; or true

