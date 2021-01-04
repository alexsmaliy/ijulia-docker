Commands
========

| Script | Action |
| ---:  | :---   |
| [generate-cert.sh](./generate-cert.sh) | Interactive script to generate a dummy CA and use it to sign a cert **for use with Jupyter.** If a cert is present, `docker-compose` will mount it in the container and tell Jupyter to use HTTPS. Re-running this script will re-generate the leaf cert, not the CA. |
| [launch.sh](./launch.sh) | Downloads parent images. Builds local image. Launches containers. Trails logs until interrupted. |
| [start.sh](./start.sh) | Starts containers for a service. Launches a new one if there isn't one already. |
| [stop.sh](./stop.sh) | Stops containers for a service, if they exist. |
| [status.sh](./status.sh) | Prints the status of a container. |
| [follow-logs.sh](./follow-logs.sh) | Attaches to a running or stopped container and prints a running view of `STDOUT`/`STDERR` of PID 1. |
| [shell.sh](./shell.sh) | Open a shell as a non-root user in a container. |
| [destroy.sh](./destroy.sh) | Stops *and removes* the container for the specified service. |


Workflow
========
1. [Optional, Jupyter-only] Run `generate-cert.sh` to generate a cert. Record your CA key pass phrase.
1. Run `launch.sh <jupyter|pluto>` to create a new container.
1. Use `stop.sh <jupyter|pluto>` and `start.sh <jupyter|pluto>` to manage containers.
1. Use `destroy.sh <jupyter|pluto>` if you need to tear down and rebuild. Destroying the container will also remove all user-imported libraries, but not files located in the shared filesystem volumes `./work` an `./work-pluto`.
