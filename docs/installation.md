---
title: Installation
nav_order: 3
---

# Installing and building
{: .no_toc }

1. TOC
{:toc}

UNIXCMD is distributed as source code. To install it, upload the source
into source physical files on your IBM i, then compile it with the
supplied `BUILDIT` CL program.

## Requirements

| Component | Minimum release |
|---|---|
| `UNIXPIPER4` service program, `UNIXCMD` SPECIAL file handler, CL commands, examples 1-7 | Any supported release with ILE RPG, QShell and PASE |
| `UNIXCMDOA` Open Access handler | V6R1 or later (BUILDIT skips it on older releases). RPG Open Access itself needs the right release/PTF level on your system. |
| `EXAMPLE8` (free-format `DCL-F ... SPECIAL`) | 7.1 or later, with the free-format RPG PTFs |
| `EXAMPLE9` through `EXAMPLE11` (`**FREE` + Open Access) | 7.2 or later, with the required PTFs |

To use PASE mode or PASE programs, the PASE option of the operating system
(5770-SS1 option 33) must be installed. To run open-source tools such as
Node.js, Python or PHP, those tools must also be installed, for example
with `yum`.

## Repository layout

```
src/
  qrpglesrc/   RPG source: handlers, service program, CPPs, copybooks
  qcmdsrc/     CL command definitions (OPNPIPE, SNDPIPE, RCVPIPE, CLOPIPE)
  qpnlsrc/     Help panel groups for the CL commands
  qclsrc/      BUILDIT: compiles everything
  upload.bat   Windows FTP upload script
samples/
  rpg/         Example programs EXAMPLE1 - EXAMPLE11
  php_geocode/ PHP script used by EXAMPLE7
```

## Step 1: Upload the source

### Option A: automatic FTP upload (Windows)

`src/upload.bat` creates a library and the source files, uploads every
member, and sets each member's source type. It needs FTP access to the
IBM i.

```bat
src\upload.bat YOUR-HOST YOUR-LIB YOUR-USERID YOUR-PASSWORD
```

| Argument | Meaning |
|---|---|
| `YOUR-HOST` | Host name or IP address of the IBM i |
| `YOUR-LIB` | Library to create and put the source into |
| `YOUR-USERID` | User profile to sign on with |
| `YOUR-PASSWORD` | Password for that profile |

The script creates the following source files in `YOUR-LIB`:

| Source file | Record length | Contents |
|---|---|---|
| `QCLSRC` | 92 | `BUILDIT` |
| `QCMDSRC` | 92 | `OPNPIPE`, `SNDPIPE`, `RCVPIPE`, `CLOPIPE` |
| `QPNLSRC` | 92 | Help panel groups for the four commands |
| `QRPGLESRC` | 112 | Everything else, including the `EXAMPLEn` members from `samples/rpg` |

{: .warning }
FTP sends your password in clear text, and the script also writes it to a
temporary FTP script file in the `src` directory while it runs. Use it only
on a network you trust.

### Option B: upload manually

Use any method you like, such as FTP in ASCII mode, RDi, or VS Code with
Code for IBM i. Put each file into the member shown in
[INSTALLATION.md](https://github.com/ThePrez/UNIXCMD-IBMi/blob/main/INSTALLATION.md)
and set the source type (`RPGLE`, `CMD`, `PNLGRP`, `CLP`).

## Step 2: Compile

1. Make sure the library that holds the source is in your library list.
2. Set your current library to the library that should receive the
   compiled objects.
3. Compile and run the build program:

   ```
   CRTCLPGM PGM(BUILDIT) SRCFILE(QCLSRC)
   CALL PGM(BUILDIT)
   ```

`BUILDIT` checks the operating system release with the `QSZRTVPR` API and
then creates these objects:

| Object | Type | Notes |
|---|---|---|
| `UNIXPIPER4` | `*SRVPGM` | Core routines. `EXPORT(*ALL)`, bound to `QC2LE`. |
| `UNIXCMD` | `*PGM` | SPECIAL file handler, `ACTGRP(UNIXCMD)` |
| `UNIXCMDOA` | `*PGM` | Open Access handler, `ACTGRP(UNIXCMD)`. Only built on V6R1 and later. |
| `OPNPIPER4`, `SNDPIPER4`, `RCVPIPER4`, `CLOPIPER4` | `*PGM` | Command processing programs, `ACTGRP(UNIXCMD)` |
| `OPNPIPE`, `SNDPIPE`, `RCVPIPE`, `CLOPIPE` | `*CMD` | `ALLOW(*IPGM *IMOD *BPGM *BMOD)`, so they can only be used in programs |
| `OPNPIPE`, `SNDPIPE`, `RCVPIPE`, `CLOPIPE` | `*PNLGRP` | Help text for the commands |
| `EXAMPLE1` - `EXAMPLE11` | `*PGM` | Sample programs. Examples 8-11 are built only on newer releases, and failures are ignored with `MONMSG`. |

## Step 3: Verify

Run the simplest sample, which lists the contents of `/tmp` to a spooled
file:

```
CALL PGM(EXAMPLE1)
WRKSPLF
```

If you see a `QSYSPRT` spooled file listing the files in `/tmp`,
UNIXCMD is working.

## Using UNIXCMD from your own programs

- The library that holds the UNIXCMD objects must be in the library list
  when your program runs, or you must qualify the handler name, for example
  `handler('MYLIB/UNIXCMDOA': cmd)`.
- Using the [procedure API](api.md) directly from your own ILE code? Copy
  `UNIXPIPE_H` into your source with `/copy` and bind to the `UNIXPIPER4`
  service program.

## Rebuilding a single object

The top of each source member shows the commands to compile just that
object. For example, from `UNIXCMDOA`:

```
CRTRPGMOD UNIXCMDOA DBGVIEW(*LIST)
CRTPGM UNIXCMDOA ACTGRP(UNIXCMD) BNDSRVPGM(UNIXPIPER4)
```

{: .note }
The comments at the top of `UNIXCMD` and `UNIXCMDOA` show
`ACTGRP(KLEMENT)`, but `BUILDIT` uses `ACTGRP(UNIXCMD)`. Use the same
activation group as the rest of your build so all the programs share the
service program's state.
