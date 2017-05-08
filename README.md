# akabe/iocaml

Minimal environment for ready-to-use [Jupyter notebook](http://ipython.org/notebook.html) with [IOCaml kernel](https://github.com/andrewray/iocaml).

```
docker run -it -p 8888:8888 akabe/iocaml
```

You can use notebooks on the host machine by

```
docker run -it -p 8888:8888 -v $(pwd):/notebooks akabe/iocaml
```

## Examples

```
git clone git@github.com:akabe/docker-iocaml.git
cd docker-iocaml/examples
docker run -it -p 8888:8888 -v $(pwd):/notebooks akabe/iocaml
```

## Distributions

The default `latest` version is the following distribution:

| Distribution | OCaml | OPAM | Command |
| ------------ | ----- | ---- | ------- |
| Alpine 3.5 | 4.04.1 | 1.2.2 | `docker pull akabe/iocaml` |

### Alpine

| Distribution | OCaml | OPAM | Command |
| ------------ | ----- | ---- | ------- |
| Alpine 3.5 | 4.05.0+trunk | 1.2.2 | `docker pull akabe/iocaml:alpine3.5_ocaml4.05.0` |
| Alpine 3.5 | 4.04.1 | 1.2.2 | `docker pull akabe/iocaml:alpine3.5_ocaml4.04.1` |
| Alpine 3.5 | 4.03.0 | 1.2.2 | `docker pull akabe/iocaml:alpine3.5_ocaml4.03.0` |
| Alpine 3.5 | 4.02.3 | 1.2.2 | `docker pull akabe/iocaml:alpine3.5_ocaml4.02.3` |
