FROM akabe/opam:latest

ENV PATH $PATH:$HOME/.local/bin

RUN sudo apk add --upgrade --no-cache m4 zeromq-dev libffi-dev python3-dev && \
    pip3 install --user --no-cache jupyter && \
    opam install -y lwt=2.7.1 ounit=2.0.0 ocp-index iocaml-kernel && \
    \
    rm -rf $HOME/.cache \
           $HOME/.opam/archives \
           $HOME/.opam/repo/default/archives \
           $HOME/.opam/$OCAML_VERSION/build

COPY entrypoint.sh /
COPY .jupyter $HOME/.jupyter
COPY .iocamlinit $HOME/.iocamlinit
COPY kernel.json /tmp

RUN sudo mkdir /notebooks && \
    sudo chown opam $HOME/.iocamlinit $HOME/.jupyter /tmp/kernel.json && \
    eval $(opam config env) && \
    sed -i "s#__IOCAML_EXECUTABLE__#$(which iocaml.top)#" /tmp/kernel.json && \
    sed -i "s#__IOCAML_LOG__#$HOME/.jupyter/iocaml.log#" /tmp/kernel.json && \
    jupyter kernelspec install --user --name iocaml-kernel /tmp && \
    rm -f /tmp/kernel.json

VOLUME /notebooks
WORKDIR /notebooks

EXPOSE 8888

ENTRYPOINT [ "/entrypoint.sh" ]
CMD ["jupyter", "notebook", "--no-browser", "--config", "$HOME/.jupyter/jupyter_notebook_config.py"]
