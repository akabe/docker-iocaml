FROM akabe/ocaml:alpine3.5_ocaml4.03.0

ENV PATH $PATH:/home/opam/.local/bin

RUN sudo apk add --upgrade --no-cache curl make patch gcc m4 zeromq libffi python3 && \
    sudo apk add --upgrade --no-cache \
                 --virtual=.build-dependencies \
                 zeromq-dev libffi-dev python3-dev && \
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
    sudo apk del .build-dependencies

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
