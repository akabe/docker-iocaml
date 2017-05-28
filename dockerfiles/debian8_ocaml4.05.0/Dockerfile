FROM akabe/ocaml:debian8_ocaml4.05.0

ENV PATH $PATH:/home/opam/.local/bin

RUN sudo apt-get update && \
    sudo apt-get upgrade -y && \
    sudo apt-get install -y libzmq3 libffi6 python3 python3-pip \
                            curl gcc m4 pkg-config libzmq3-dev libffi-dev python3-dev && \
    \
    eval $(opam config env) && \
    \
    sudo pip3 install --upgrade pip && \
    pip3 install --user --no-cache-dir jupyter && \
    opam install -y lwt=2.7.1 ounit=2.0.0 ocp-index iocaml-kernel && \
    \
    find /home/opam/.opam -regex '.*\.\(cmt\|cmti\|annot\|byte\)' -delete && \
    rm -rf /home/opam/.opam/archives \
           /home/opam/.opam/repo/default/archives \
           /home/opam/.opam/$OCAML_VERSION/build && \
    \
    sudo apt-get purge -y libzmq3-dev libffi-dev python3-dev && \
    sudo apt-get autoremove -y && \
    sudo apt-get autoclean

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
