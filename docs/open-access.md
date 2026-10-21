---
title: RPG Open Access
nav_order: 4
---

# Using UNIXCMD with RPG Open Access
{: .no_toc }

1. TOC
{:toc}

The `UNIXCMDOA` program is an RPG Open Access *handler*. With Open Access,
you declare a file with the `HANDLER` keyword, and the normal RPG file
operations (`OPEN`, `READ`, `WRITE`, `CLOSE`) are passed to the handler
instead of to a database or device file. `UNIXCMDOA` turns them into
operations on a Unix process.

If your system supports Open Access, this is the recommended interface.

## Declaring the file

```rpgle
dcl-f UNIX disk(1000) usage(*input:*output) handler('UNIXCMDOA': cmd) usropn;
dcl-s cmd char(5000);
```

| Part | Meaning |
|---|---|
| `disk(1000)` | The record length, which is the most bytes one `READ` or `WRITE` can transfer. Choose a length longer than the longest line you expect. |
| `usage(...)` | `*input` to read output, `*output` to send input, or both |
| `handler('UNIXCMDOA': cmd)` | The handler program and its *user area*. `UNIXCMDOA` uses the user area as the command to run. |
| `usropn` | Lets you set `cmd` before the file is opened. Leave it out only if `cmd` already has its value when the program starts (for example, with `inz(...)`). |

{: .important }
The user area must be a fixed-length `char(5000)` field. `UNIXCMDOA`
reads exactly 5000 bytes from the address it's given and trims trailing
blanks. A shorter field would make it read whatever storage follows the
field, and a `varchar` field would include its length prefix in the
command.

## Operations

| RPG operation | What `UNIXCMDOA` does |
|---|---|
| `OPEN` | Removes any environment prefix (see below) and starts the command |
| `WRITE` / `UPDATE` | Trims trailing blanks from the record, adds a line feed, and writes the result to the command's stdin |
| `READ` | Reads one line from the command's stdout/stderr. `%EOF` is set on when there's no more output. |
| `FEOD` | Closes the command's stdin, which tells it there's no more input |
| `CLOSE` | Closes the pipes, waits for the command to end, and checks the exit status |

Any other operation (`CHAIN`, `SETLL`, `DELETE`, and so on) fails with
status 1299.

## Choosing the command environment

By default the command runs in **QShell**. To choose another environment,
start the command with a prefix and a colon. The prefix isn't
case-sensitive.

| Prefix | Environment |
|---|---|
| *(none)* | QShell |
| `qsh:` or `qshell:` | QShell |
| `pase:` | PASE, using `/QOpenSys/usr/bin/sh` |
| `raw:` | Raw. The rest of the string is the path of the program to spawn, with no arguments. |

```rpgle
cmd = 'pase:cd /tmp; ls';
```

{: .note }
UNIXCMDOA looks only at the first colon in the command. It treats the text
before it as a prefix only when that text is 2 to 8 characters long and is
one of the values above. Commands such as `ls -l /tmp` or
`echo key:value` aren't affected.

See [Command environments](concepts.md#command-environments) for the
differences between the environments.

## Example: reading output

This is `EXAMPLE9`. It lists the `/tmp` directory and prints one line per
file:

```rpgle
**FREE
dcl-f UNIX disk(1000) handler('UNIXCMDOA': cmd) usropn;
dcl-f QSYSPRT printer(132) usage(*output);
dcl-s cmd char(5000);
dcl-ds record len(1000) end-ds;
dcl-ds outrec len(132) end-ds;

cmd = 'cd /tmp; ls';
open UNIX;

read UNIX record;
dow not %eof(UNIX);
   outrec = record;
   write QSYSPRT outrec;
   read UNIX record;
enddo;

*inlr = *on;
```

## Example: sending input, then reading the result

This is `EXAMPLE10`. It sends five ASCII bytes (`x'48656c6c6f'`, which is
"Hello") to `iconv`. `iconv` converts them from CCSID 819 (ASCII) to
CCSID 0 (the job's CCSID), and the program reads the result back. Because
`cmd` is initialized with `inz`, the file doesn't need `usropn`.

```rpgle
**FREE
dcl-f UNIX disk(5) usage(*input:*output) handler('UNIXCMDOA':cmd);
dcl-s cmd char(5000) inz('iconv -f 819 -t 0');
dcl-ds record len(5) end-ds;
dcl-c AsciiData x'48656c6c6f';

record = AsciiData;
write UNIX record;
read UNIX record;
dsply record;

*inlr = *on;
```

## Example: a Node.js program with structured replies

This example from the presentation runs a Node.js program called
`geocode.js`. The program reads a street address from stdin, calls the US
Census Bureau geocoding REST API, and writes the latitude and longitude to
stdout. If something goes wrong, it writes a line starting with `err`. The
RPG program uses a data structure to split each reply into a type and the
data.

```rpgle
**free
ctl-opt dftactgrp(*no);
dcl-f UNIX disk(1000) usage(*input:*output) handler('UNIXCMDOA': cmd) usropn;

dcl-pr putenv int(10) extproc(*dclcase);
  varval pointer value options(*string);
end-pr;

dcl-s cmd char(5000);
dcl-s lat packed(11: 7);
dcl-s lon packed(11: 7);
dcl-s msg char(52);

dcl-ds record qualified;
  type char(3);
  *n   char(1);
  data char(996);
end-ds;

putenv('QIBM_MULTI_THREADED=Y');
cmd = 'cd geocode && node geocode.js';
open UNIX;

record = '8825 S. Howell Avenue Ste 301, Oak Creek, WI 53154';
write UNIX record;

read UNIX record;
if record.type = 'err';
  close UNIX;
  msg = record.data;
  dsply msg;
  return;
endif;
lat = %dec(record.data: 11: 7);

read UNIX record;
lon = %dec(record.data: 11: 7);

msg = 'coords=' + %char(lat) + ',' + %char(lon);
dsply msg;

close UNIX;
*inlr = *on;
```

Points to note:

- `putenv('QIBM_MULTI_THREADED=Y')` runs before `OPEN`, so the child
  process inherits it. Node.js uses threads, and QShell only starts
  processes that can create threads when this variable is `Y`.
- `cd geocode && node geocode.js` is a relative path. It's resolved from
  the job's current directory, usually the user's home directory.
- All input is written before the first `READ`. See
  [Write first, then read](data-handling.md#write-first-then-read).

([Klement](references.md#sources))

## Error handling

`UNIXCMDOA` reports problems through the standard RPG file status codes.
You can catch them with `MONITOR`, an `(E)` extender plus `%ERROR` /
`%STATUS`, an `INFSR`, or a `*PSSR`.

| Status | Set when |
|---|---|
| 1211 | An I/O operation was attempted while no command is running |
| 1215 | `OPEN` was issued while the file is already open |
| 1217 | `OPEN` failed (no user area, or the process couldn't be started), **or** `CLOSE` found that the command ended with a non-zero exit status or because of a signal |
| 1299 | A `WRITE` failed (for example, after stdin was closed), or the operation isn't supported |

```rpgle
monitor;
   close UNIX;
on-error 1217;
   // The command reported a failure. Look in the job log for
   // "Child process ended with status n".
endmon;
```

Whenever the service program records an error, it also writes a `CPF9897`
diagnostic message to the job log. See [Troubleshooting](troubleshooting.md).

## Leaving the file open

As with any RPG file, the file is closed automatically when the program
ends with `*INLR` on. Some samples rely on this and never code `CLOSE`.
An explicit `CLOSE` is better, because it's where you find out whether the
command worked.
