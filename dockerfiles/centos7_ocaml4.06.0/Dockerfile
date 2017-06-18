FROM akabe/ocaml:centos7_ocaml4.06.0

ENV PATH $PATH:/home/opam/.local/bin

RUN sudo yum install -y epel-release && \
    sudo yum install -y curl zeromq3 libffi python34 python34-pip \
                        which gcc m4 zeromq3-devel libffi-devel python34-devel && \
    \
    eval $(opam config env) && \
    \
    sudo pip3 install --upgrade pip && \
    pip3 install --user --no-cache-dir jupyter && \
    opam install -y 'lwt>=3.0.0' 'ounit>=2.0.0' ocp-index iocaml-kernel && \
    \
    find /home/opam/.opam -regex '.*\.\(cmt\|cmti\|annot\|byte\)' -delete && \
    rm -rf /home/opam/.cache \
           /home/opam/.opam/archives \
           /home/opam/.opam/repo/default/archives \
           /home/opam/.opam/$OCAML_VERSION/build && \
    \
    sudo yum clean all

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
