FROM akabe/ocaml:centos6_ocaml4.05.0

ENV PATH $PATH:/home/opam/.local/bin

RUN sudo yum install -y https://centos6.iuscommunity.org/ius-release.rpm && \
    sudo yum install -y zeromq3 libffi python35u python35u-pip \
                        which gcc m4 zeromq3-devel libffi-devel python35u-devel && \
    \
    eval $(opam config env) && \
    \
    sudo pip3.5 install --upgrade pip && \
    pip3.5 install --user --no-cache-dir jupyter && \
    opam install -y lwt=2.7.1 ounit=2.0.0 ocp-index iocaml-kernel && \
    \
    find /home/opam/.opam -regex '.*\.\(cmt\|cmti\|annot\|byte\)' -delete && \
    rm -rf /home/opam/.opam/archives \
           /home/opam/.opam/repo/default/archives \
           /home/opam/.opam/$OCAML_VERSION/build && \
    \
    sudo yum remove -y zeromq3-devel python35u-devel && \
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
