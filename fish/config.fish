if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Zig
fish_add_path /opt/zig/

# For jdtls (with Lombok)
set -gx JDTLS_JVM_ARGS "-javaagent:$HOME/.local/share/eclipse/lombok.jar"

# OCaml
source ~/.opam/opam-init/init.fish > /dev/null 2> /dev/null; or true

