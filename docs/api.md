---
title: API reference
nav_order: 8
---

# UNIXPIPER4 procedure API
{: .no_toc }

1. TOC
{:toc}

The Open Access handler, the SPECIAL file handler and the CL commands are
all thin layers over the `UNIXPIPER4` service program. You can call its
procedures directly from any ILE program when you need more control, for
example to read a line into a `varchar` field, use a different
end-of-line character, check how a process ended, or manage several
processes at once.

## Setup

```rpgle
ctl-opt dftactgrp(*no) actgrp(*caller);   // or a named activation group

/copy UNIXPIPE_H
```

Bind to the service program when you create the program:

```
CRTRPGMOD MODULE(MYPGM) SRCFILE(QRPGLESRC)
CRTPGM PGM(MYPGM) MODULE(MYPGM) BNDSRVPGM(UNIXPIPER4)
```

To use `CRTBNDRPG`, add `UNIXPIPER4` to a binding directory and name that
directory with `BNDDIR`.

## Lifecycle

```rpgle
dcl-s p      pointer;
dcl-s line   varchar(1000);
dcl-s eType  uns(5);
dcl-s eCode  uns(5);

p = pipe_open('cd /tmp && ls -l': 'Q');
if p = *null;
   dsply %subst(pipe_error(): 1: 52);
   return;
endif;

dow pipe_read(p: line) <> -1;
   // process line
enddo;

if pipe_close(p: eType: eCode) = -1;
   // eType = PIPE_NORMAL, PIPE_SIGNAL, ...; eCode = exit status/signal
endif;
```

## Procedures

### pipe_open

Starts a process and connects pipes to its stdin, stdout and stderr.

```rpgle
D pipe_open       pr              *
D   cmd                      65535a   varying const options(*varsize)
D   type                         1a   const options(*nopass:*omit)
```

| Parameter | Description |
|---|---|
| `cmd` | The command line, up to 65535 characters |
| `type` | `Q` for QShell (the default), `P` for PASE (`/QOpenSys/usr/bin/sh -c`), or `' '` for raw. In raw mode, `cmd` is the path of the program to spawn, and no arguments are passed. |

**Returns** a handle (pointer) to the connection, or `*NULL` on error. On
error, call `pipe_error()` for the details.

The child process inherits every environment variable in your job. It also
gets `QIBM_USE_DESCRIPTOR_STDIO=I` and `QIBM_PASE_DESCRIPTOR_STDIO=T`
unless they're already set. See
[Environment variables set by UNIXCMD](concepts.md#environment-variables-set-by-unixcmd).

### pipe_write / pipe_writef / pipe_writeb

Write one line to the process's stdin. The end-of-line character(s) are
added after the data.

```rpgle
D pipe_write      pr            10i 0
D   pip                           *   value
D   line                     65535a   varying const options(*varsize)

D pipe_writef     pr            10i 0 opdesc
D   pip                           *   value
D   line                     65535a   const options(*varsize)

D pipe_writeb     pr            10i 0
D   pip                           *   value
D   buf                           *   value
D   len                         10u 0 value
```

| Variant | Data source |
|---|---|
| `pipe_write` | A `varchar` value. Its current length is written. |
| `pipe_writef` | A fixed-length field. The whole field is written, including trailing blanks. |
| `pipe_writeb` | `len` bytes starting at the pointer `buf` |

**Returns** the number of bytes written, including the end-of-line
character, or `-1` on error. Writing fails once stdin has been closed by
`pipe_done()` or by the first read (error 90002,
`Pipe has already been marked "done"`).

### pipe_read / pipe_readf / pipe_readb

Read one line from the process's stdout/stderr.

```rpgle
D pipe_read       pr            10i 0 opdesc
D   pip                           *   value
D   line                     65535a   varying options(*varsize)

D pipe_readf      pr            10i 0 opdesc
D   pip                           *   value
D   line                     65535a   options(*varsize)

D pipe_readb      pr            10i 0
D   pip                           *   value
D   buf                           *   value
D   size                        10u 0 value
```

| Variant | Destination |
|---|---|
| `pipe_read` | A `varchar` field. Its length is set to the number of bytes read. Both 2-byte and 4-byte length prefixes are supported. |
| `pipe_readf` | A fixed-length field, padded with blanks |
| `pipe_readb` | A buffer of `size` bytes at the pointer `buf`, padded with blanks |

**Returns** the length of the line, without the end-of-line character, or
`-1` at end of file or on error. If the line is longer than the
destination, the rest of it is returned by the next call.

{: .important }
The first read automatically calls `pipe_done()`, which closes the
process's stdin. Do all your writing before you read.

### pipe_done

Closes the process's stdin, which signals end of input. Stdout stays open
and the process keeps running. This procedure always succeeds.

```rpgle
D pipe_done       pr
D   pip                           *   value
```

### pipe_close

Closes both pipes, frees the handle, and waits for the process to end.

```rpgle
D pipe_close      pr            10i 0
D   pip                           *   value
D   exitType                     5u 0 options(*nopass:*omit)
D   exitCode                     5u 0 options(*nopass:*omit)

D PIPE_NORMAL     C                   0
D PIPE_SIGNAL     C                   2
D PIPE_STOPPED    C                   4
D PIPE_EXCP       C                   4
```

| Parameter | Description |
|---|---|
| `exitType` | Optional. How the process ended: `PIPE_NORMAL`, `PIPE_SIGNAL`, `PIPE_STOPPED`, or `PIPE_EXCP`. |
| `exitCode` | Optional. The exit status (for a normal end), or the signal or exception number |

**Returns** `0` if the process ended normally with exit status 0.
Otherwise it returns `-1` and sets `pipe_error()` to a message such as
`Child process ended with status 2` or `Child process ended by signal n`.

{: .note }
`PIPE_STOPPED` and `PIPE_EXCP` have the same value in the copybook, so
`pipe_close` can't tell them apart.

### pipe_setEol

Sets the end-of-line character(s) for one connection. The default is
`x'25'` (line feed). Use up to two characters.

```rpgle
D pipe_setEol     pr
D   pip                           *   value
D   newEol                       2a   varying const
```

```rpgle
pipe_setEol(p: x'0d25');   // CR LF
```

### pipe_error

Returns the most recent error recorded by the service program.

```rpgle
D pipe_error      pr            80a   varying
D   errnum                      10i 0 options(*omit:*nopass)
```

`errnum` receives the error number. This is the C `errno` for system
errors, or one of UNIXCMD's own codes (90001: null pipe, 90002: pipe
already marked done). The procedure returns the message text.

Each recorded error is also written to the job log as a `CPF9897`
diagnostic message.

### pipe_getId / pipe_getHandle

Convert between a handle and a numeric *pipe ID*. The CL commands use
these, because CL can't store pointers.

```rpgle
D pipe_getId      pr            10i 0
D   pip                           *   value

D pipe_getHandle  pr              *
D   pipeid                      10i 0 value
```

- `pipe_getId` returns the pipe ID, or `-1` if the handle is null. The ID
  is the descriptor number of the read end of the output pipe.
- `pipe_getHandle` returns the handle for a pipe ID, or `*NULL` if there
  isn't one. The special value `-2` returns the most recently opened pipe.
  This is what `*DFT` means on the CL commands.

The table of open pipes is kept in the service program's storage, so it's
scoped to the activation group. Only pipe IDs 1-1000 are tracked.
