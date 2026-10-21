# UNIXCMD for IBM i

UNIXCMD lets RPG programs on IBM i run Unix (PASE/QShell) commands and
interact with their input and output streams as if they were ordinary files.

Originally written by Scott Klement.

## Components

- **UNIXCMD** – handler for the RPG `SPECIAL` file interface.
- **UNIXCMDOA** – handler for RPG Open Access (`HANDLER` keyword).
- **UNIXPIPER4** – service program that launches commands and reads/writes
  their data streams.
- **OPNPIPE / SNDPIPE / RCVPIPE / CLOPIPE** – CL commands for opening a pipe
  to a Unix command, sending and receiving data, and closing it.

## Repository layout

```
src/
  qrpglesrc/   RPG source (handlers, service program, copybooks)
  qcmdsrc/     CL command definitions
  qpnlsrc/     Help panel groups for the commands
  qclsrc/      BUILDIT build program
  upload.bat   FTP upload script
samples/
  rpg/         Example RPG programs (example1 – example11)
  php_geocode/ PHP script used by the PHP integration example
```

## Documentation

Full documentation lives in the [docs](docs/) directory, which is published
with GitHub Pages. It covers concepts, the Open Access and SPECIAL file
interfaces, the CL commands, the `UNIXPIPER4` API, data handling, the
samples, and troubleshooting.

## Installation

See [INSTALLATION.md](INSTALLATION.md) for upload and build instructions,
or the [installation guide](docs/installation.md) in the docs.

## License

BSD-style license. See the copyright notice at the top of each source file.
