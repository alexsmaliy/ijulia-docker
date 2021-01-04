FROM julia:1.5.3-alpine3.12

# The value of this build arg is set dynamically in docker-compose.yml.
ARG PLUTO_UID

RUN adduser --disabled-password --uid $PLUTO_UID pluto; \
    mkdir /home/pluto/work-pluto; \
    chmod g+s /home/pluto/work-pluto;

USER pluto

RUN julia -e 'import Pkg; \
              Pkg.add(Pkg.PackageSpec(;name="Pluto", version="v0.12.18")); \
              Pkg.precompile();'
