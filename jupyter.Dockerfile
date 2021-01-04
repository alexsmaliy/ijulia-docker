FROM jupyter/datascience-notebook:latest

RUN julia -e 'import Pkg; \
              Pkg.add(Pkg.PackageSpec(;name="RDatasets", version="0.7.1")); \
              Pkg.add(Pkg.PackageSpec(;name="Gadfly", version="1.3.1")); \
              Pkg.precompile();'
