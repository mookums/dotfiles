if status is-interactive
    # Commands to run in interactive sessions can go here
end

# /usr/local/bin
fish_add_path /usr/local/bin/

# For jdtls (with Lombok)
set -gx JDTLS_JVM_ARGS "-javaagent:$HOME/.local/share/eclipse/lombok.jar"

# OCaml
source ~/.opam/opam-init/init.fish > /dev/null 2> /dev/null; or true

# Kiboigo Source
source ~/.kiboigo/kiboigo.fish
