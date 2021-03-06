FROM julia:1.5.3-buster

# The value of this build arg is set dynamically in docker-compose.yml.
ARG PLUTO_UID

# Debian Buster complains if GECOS is not set for the new user.
# Set it to all empty fields.
RUN adduser \
      --disabled-password \
      --uid $PLUTO_UID \
      --gecos ',,,' \
      pluto; \
    mkdir /home/pluto/work-pluto; \
    chmod g+s /home/pluto/work-pluto;

USER pluto

RUN julia -e 'import Pkg; \
              Pkg.add(Pkg.PackageSpec(;name="Pluto", version="v0.12.18")); \
              Pkg.precompile();'
