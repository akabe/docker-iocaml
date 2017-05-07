#!/bin/bash -eu

##
## dockerfile.sh
##
##   Usage: ./dockerfile.sh
##
##   Generate Dockerfile(s) for akabe/ocaml Docker images and publish them to github.com.
##

function print_dockerfile_header() {
    cat <<EOF
FROM akabe/ocaml:${TAG}

ENV PATH \$PATH:\$HOME/.local/bin

EOF
}

function print_dockerfile_footer() {
    cat <<'EOF' >>Dockerfile

VOLUME /notebooks
WORKDIR /notebooks

EXPOSE 8888

ENTRYPOINT [ "/entrypoint.sh" ]
CMD ["jupyter", "notebook", "--no-browser"]
EOF
}

function print_dockerfile_alpine_script() {
    cat <<'EOF'
RUN sudo apk add --upgrade --no-cache zeromq libffi python3 \
                                      m4 zeromq-dev libffi-dev python3-dev && \
    \
    pip3 install --user --no-cache jupyter && \
    opam install -y lwt=2.7.1 ounit=2.0.0 ocp-index iocaml-kernel && \
    \
    sudo apk del m4 zeromq-dev libffi-dev python3-dev
EOF
}

function print_dockerfile_common_script() {
    cat <<'EOF'
    find $HOME/.opam -regex '.*\\.\\(cmt\\|cmti\\|annot\\|byte\\)' -delete && \
    rm -rf $HOME/.cache \
           $HOME/.opam/archives \
           $HOME/.opam/repo/default/archives \
           $HOME/.opam/$OCAML_VERSION/build

COPY .iocamlinit   $HOME/.iocamlinit
COPY .jupyter      $HOME/.jupyter
COPY entrypoint.sh /

RUN eval $(opam config env) && \
    sudo chown opam $HOME/.iocamlinit $HOME/.jupyter && \
    \
    sed -i "s#__IOCAML_EXECUTABLE__#$(which iocaml.top)#" $HOME/.jupyter/kernel.json && \
    sed -i "s#__IOCAML_LOG__#$HOME/.jupyter/iocaml.log#" $HOME/.jupyter/kernel.json && \
    jupyter kernelspec install --user --name iocaml-kernel $HOME/.jupyter && \
    \
    sudo rm -rf $HOME/.jupyter/kernel.json
EOF
}

function print_kernel_json() {
    cat <<EOF
{
  "display_name": "OCaml ${OCAML}",
  "language": "ocaml",
  "argv": [
    "/home/opam/.opam/${OCAML}/bin/iocaml.top",
    "-log",
    "/home/opam/.jupyter/iocaml.log",
    "-object-info",
    "-completion",
    "-connection-file",
    "{connection_file}"
  ]
}
EOF
}

function print_entrypoint_sh() {
    cat <<'EOF'
#!/bin/sh
sudo chown -hR opam:opam /notebooks
opam config exec -- "$@"
EOF
}

function print_iocamlinit() {
    cat <<'EOF'
(* Added by OPAM. *)
let () =
  try Topdirs.dir_directory (Sys.getenv "OCAML_TOPLEVEL_PATH")
  with Not_found -> ()
;;

#use "topfind";;
EOF
}

function print_jupyter_notebook_config() {
    cat <<'EOF'
c.Session.key = b''
c.NotebookApp.ip = '*'
EOF
}

function print_dockerignore() {
    cat <<'EOF'
README.md
LICENSE
EOF
}

FIRST_COMMIT=9944265c6300ea4aa65f626e4d42c1e1d3f1b77a

ENVIRONMENTS=(
    'TAG=latest                OCAML=4.04.1'
    'TAG=alpine3.5_ocaml4.05.0 OCAML=4.05.0+trunk'
    'TAG=alpine3.5_ocaml4.04.1 OCAML=4.04.1'
    'TAG=alpine3.5_ocaml4.03.0 OCAML=4.03.0'
    'TAG=alpine3.5_ocaml4.02.3 OCAML=4.02.3'
)

git checkout master

README="$(cat README.md)" # Capture README.md at master

for env_decl in "${ENVIRONMENTS[@]}"; do
    eval "$env_decl" # Expand variables
    BRANCH="release/${TAG}" # branch name

    # Checkout a branch
    if [[ -f ".git/refs/heads/$BRANCH" ]]; then
       git checkout $BRANCH
    else
       git checkout $FIRST_COMMIT -b $BRANCH
    fi

    # Create files
    mkdir -p .jupyter
    echo "${README}"              >README.md
    print_entrypoint_sh           >entrypoint.sh
    print_dockerignore            >.dockerignore
    print_iocamlinit              >.iocamlinit
    print_kernel_json             >.jupyter/kernel.json
    print_jupyter_notebook_config >.jupyter/jupyter_notebook_config.py

    print_dockerfile_header >Dockerfile
    if [[ "$TAG" == latest ]] || [[ "$TAG" =~ ^alpine ]]; then
        print_dockerfile_alpine_script >>Dockerfile
    else
        echo "[Error] Unknown base image: $TAG"
        exit 1
    fi
    print_dockerfile_common_script >>Dockerfile
    print_dockerfile_footer        >>Dockerfile

    # Commit changes
    git add README.md Dockerfile entrypoint.sh .iocamlinit .jupyter .dockerignore
    if git commit -m 'updated distribution files'; then
        git push git@github.com:akabe/docker-iocaml.git $BRANCH
    fi
done
