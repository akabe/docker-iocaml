#!/bin/bash -eu

function iocaml_scripts() {
    local pip=$1

    cat <<EOF
    eval \$(opam config env) && \\
    \\
    sudo ${pip} install --upgrade pip && \\
    ${pip} install --user --no-cache-dir jupyter && \\
    opam install -y 'lwt>=3.0.0' 'ounit>=2.0.0' ocp-index iocaml-kernel && \\
    \\
    find /home/opam/.opam -regex '.*\\.\\(cmt\\|cmti\\|annot\\|byte\\)' -delete && \\
    rm -rf /home/opam/.cache \\
           /home/opam/.opam/archives \\
           /home/opam/.opam/repo/default/archives \\
           /home/opam/.opam/\$OCAML_VERSION/build
EOF
}

function alpine_scripts() {
    cat <<EOF
RUN sudo apk add --upgrade --no-cache curl zeromq libffi python3 && \\
    sudo apk add --upgrade --no-cache \\
                 --virtual=.build-dependencies \\
                 m4 zeromq-dev libffi-dev python3-dev && \\
    \\
$(iocaml_scripts pip3) && \\
    \\
    sudo apk del .build-dependencies
EOF
}

function centos7_scripts() {
    cat <<EOF
RUN sudo yum install -y epel-release && \\
    sudo yum install -y curl zeromq3 libffi python34 python34-pip \\
                        which gcc m4 zeromq3-devel libffi-devel python34-devel && \\
    \\
$(iocaml_scripts pip3) && \\
    \\
    sudo yum clean all
EOF
}

function centos6_scripts() {
    cat <<EOF
RUN sudo yum install -y https://centos6.iuscommunity.org/ius-release.rpm && \\
    sudo yum install -y curl zeromq3 libffi python35u python35u-pip \\
                        which gcc m4 zeromq3-devel libffi-devel python35u-devel && \\
    \\
$(iocaml_scripts pip3.5) && \\
    \\
    sudo yum clean all
EOF
}

function debian_scripts() {
    cat <<EOF
RUN sudo apt-get update && \\
    sudo apt-get upgrade -y && \\
    sudo apt-get install -y libzmq3 libffi6 python3 python3-pip \\
                            curl gcc m4 pkg-config libzmq3-dev libffi-dev python3-dev && \\
    \\
$(iocaml_scripts pip3) && \\
    \\
    sudo apt-get autoremove -y && \\
    sudo apt-get autoclean
EOF
}

function ubuntu_scripts() {
    cat <<EOF
RUN sudo apt-get update && \\
    sudo apt-get upgrade -y && \\
    sudo apt-get install -y libzmq5 libffi6 python3 python3-pip \\
                            curl gcc m4 pkg-config libzmq3-dev libffi-dev python3-dev && \\
    \\
$(iocaml_scripts pip3) && \\
    \\
    sudo apt-get autoremove -y && \\
    sudo apt-get autoclean
EOF
}

echo "Generating dockerfiles/$TAG/Dockerfile (ALIAS=${ALIAS[@]})..."

rm -rf dockerfiles/$TAG
mkdir -p dockerfiles/$TAG

cat <<EOF > dockerfiles/$TAG/Dockerfile
FROM akabe/ocaml:${TAG}

ENV PATH \$PATH:/home/opam/.local/bin

EOF

if [[ "$OS" =~ ^alpine: ]]; then
    alpine_scripts >> dockerfiles/$TAG/Dockerfile
    SHELL=sh
elif [[ "$OS" =~ ^centos:7 ]]; then
    centos7_scripts >> dockerfiles/$TAG/Dockerfile
    SHELL=bash
elif [[ "$OS" =~ ^centos:6 ]]; then
    centos6_scripts >> dockerfiles/$TAG/Dockerfile
    SHELL=bash
elif [[ "$OS" =~ ^debian: ]]; then
    debian_scripts >> dockerfiles/$TAG/Dockerfile
    SHELL=bash
elif [[ "$OS" =~ ^ubuntu: ]]; then
    ubuntu_scripts >> dockerfiles/$TAG/Dockerfile
    SHELL=bash
else
    echo -e "\033[31m[ERROR] Unknown base image: ${OS}\033[0m"
    exit 1
fi

cat <<'EOF' >> dockerfiles/$TAG/Dockerfile

RUN mkdir -p /home/opam/.jupyter && \
    echo "c.Session.key = b''" > /home/opam/.jupyter/jupyter_notebook_config.py

COPY entrypoint.sh /
COPY .iocamlinit   /home/opam/.iocamlinit
COPY kernel.json   /home/opam/.jupyter/kernel.json

RUN jupyter kernelspec install --user --name iocaml-kernel /home/opam/.jupyter && \
    sudo rm -rf /home/opam/.jupyter/kernel.json

VOLUME /notebooks
WORKDIR /notebooks

EXPOSE 8888

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "jupyter", "notebook", "--no-browser", "--ip=*" ]
EOF

## .iocamlinit
cat <<'EOF' > dockerfiles/$TAG/.iocamlinit
let () =
  try Topdirs.dir_directory (Sys.getenv "OCAML_TOPLEVEL_PATH")
  with Not_found -> ()
;;

#use "topfind";;
EOF

# kernel.json
cat <<EOF > dockerfiles/$TAG/kernel.json
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

# entrypoint.sh
cat <<EOF > dockerfiles/$TAG/entrypoint.sh
#!/bin/${SHELL}
sudo chown -hR opam:opam /notebooks
opam config exec -- "\$@"
EOF

chmod +x dockerfiles/$TAG/entrypoint.sh
