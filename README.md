# akabe/iocaml

Minimal environment for ready-to-use [Jupyter notebook](http://ipython.org/notebook.html) with [IOCaml kernel](https://github.com/andrewray/iocaml).

```
docker run -it -p 8888:8888 akabe/iocaml
```

You can use notebooks on the host machine by

```
docker run -it -p 8888:8888 -v $(pwd):/notebooks akabe/iocaml
```
