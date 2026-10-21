---
title: Concepts
nav_order: 2
---

# Concepts
{: .no_toc }

1. TOC
{:toc}

## The Unix call model

A program in QShell or PASE expects:

1. its own process, rather than a new entry in the caller's call stack;
2. parameters passed by value, rather than by reference (pointer);
3. three standard streams: input, output, and error;
4. an exit status code from 0 to 255;
5. the services of a Unix shell (QShell, ksh, Bourne shell, bash, and so
   on).

Parameters are input-only and limited in length. Standard input and
standard output have no length limit, so they're how you send large
amounts of data to a program and get results back. Error messages go to
standard error.
([Klement](references.md#sources))

## Pipes

A *pipe* is a one-way channel between two processes. Whatever one process
writes into one end, the other process reads from the other end, in the
same order. You can think of it as a data queue between two jobs.

When you open a UNIXCMD file, or run `OPNPIPE`, UNIXCMD does the
following:

1. It creates two pipes with the `Qp0zPipe()` API.
2. It starts a child process with the `spawn()` API, and maps the child's
   file descriptors like this:

   | Child descriptor | Connected to |
   |---|---|
   | 0: stdin | the read end of the *input* pipe. Your writes arrive here. |
   | 1: stdout | the write end of the *output* pipe. Your reads come from here. |
   | 2: stderr | the **same** output pipe as stdout |

3. It keeps the other end of each pipe for itself. It writes to the input
   pipe and reads from the output pipe.

```
   Your RPG / CL program                     Child process
  +----------------------+   input pipe    +-------------------+
  |  WRITE / SNDPIPE  ---+---------------->| stdin  (fd 0)     |
  |                      |                 |                   |
  |  READ  / RCVPIPE  <--+-----------------+ stdout (fd 1)     |
  |                      |   output pipe   | stderr (fd 2)     |
  |  CLOSE / CLOPIPE     |                 |                   |
  +----------------------+                 +-------------------+
```

{: .note }
Standard output and standard error are **combined** into one stream. Error
messages from the command show up in your program as ordinary records,
mixed in with the normal output. See
[Detecting errors in the output](data-handling.md#detecting-errors-in-the-output)
for ways to tell them apart.

## How file operations map to the process

| RPG op (Open Access / SPECIAL) | CL command | What happens |
|---|---|---|
| `OPEN` | `OPNPIPE` | Creates the pipes and starts the command |
| `WRITE` (or `UPDATE`) | `SNDPIPE` | Sends one line to the command's stdin. Trailing blanks are trimmed (RPG only) and a line feed is added. |
| `READ` | `RCVPIPE` | Receives one line from the command's stdout/stderr |
| `FEOD` | n/a | Closes the command's stdin, which tells it there is no more input |
| `CLOSE` | `CLOPIPE` | Closes both pipes, waits for the command to end, and checks its exit status |

The **first read closes standard input**. After you start reading output,
you can't send any more input. See
[Write first, then read](data-handling.md#write-first-then-read).

When the command ends with a non-zero exit status, or is ended by a signal,
the `CLOSE` (or `CLOPIPE`) fails. In RPG, that means you get an exception
on the `CLOSE` operation unless you handle it.

## Command environments

UNIXCMD can run your command in three ways:

| Environment | How the child is started | How to choose it |
|---|---|---|
| **QShell** (default) | `/qsys.lib/qshell.lib/qzshsh.pgm -c "<cmd>"` | Open Access: no prefix, or `qsh:` / `qshell:`<br>SPECIAL: type `Q` or leave it out<br>CL: `TYPE(*QSHELL)` |
| **PASE** | `/qsys.lib/qp2shell.pgm /qopensys/usr/bin/sh -c "<cmd>"` | Open Access: `pase:` prefix<br>SPECIAL: type `P`<br>CL: `TYPE(*PASE)` |
| **Raw** | The whole command string is used as the path of the program to spawn, with no arguments | Open Access: `raw:` prefix<br>API: type `' '` |

Because QShell and PASE both run your command through a shell, you can use
anything the shell understands: `;` and `&&` to chain commands, `|`
pipelines, `>` redirection, variable assignments (`PATH=$PATH:/my/dir`),
and so on.

- `cmd1 ; cmd2` runs `cmd2` after `cmd1`, whether or not `cmd1` worked.
- `cmd1 && cmd2` runs `cmd2` only if `cmd1` worked. This is usually what
  you want with `cd`. For example, `cd /home/me && ls -1 *.zip` won't list
  the wrong directory if the `cd` fails.

Which environment should you choose? QShell is the default and runs both
QShell utilities and PASE programs. Choose PASE when you want the PASE
Bourne shell (`/QOpenSys/usr/bin/sh`) and PASE behavior for your command
line, which is common when running open-source tools installed with
`yum`.

## The PATH

When you run a command without a full path (`node`, `python3`, `php`),
the shell finds the program by searching the directories listed in the
`PATH` environment variable:

- `PATH` must be all capital letters.
- It's a list of IFS directories separated by colons. Don't put spaces
  around the colons, because a space counts as part of the directory name.
- It works like a library list, but only for finding programs.

UNIXCMD copies **every environment variable in your job** into the child
process, so the job's `PATH` is used. Set a reasonable default for the
whole system with `LEVEL(*SYS)`. Users pick up the change the next time
they sign on. For example, this includes open-source packages installed
with `yum`:

```
ADDENVVAR ENVVAR(PATH) REPLACE(*YES) LEVEL(*SYS) +
          VALUE('/usr/bin:/usr/sbin:/QOpenSys/pkgs/bin:/QOpenSys/usr/bin')
```

To change it for just one job:

```
ADDENVVAR ENVVAR(PATH) REPLACE(*YES) LEVEL(*JOB) +
          VALUE('/home/me/bin:/usr/bin:/QOpenSys/pkgs/bin:/QOpenSys/usr/bin')
```

The presentation also shows a matching `PASE_PATH` setting for PASE
programs:

```
ADDENVVAR ENVVAR(PASE_PATH) REPLACE(*YES) LEVEL(*JOB) +
          VALUE('/QOpenSys/pkgs/bin:/QOpenSys/usr/bin:/usr/bin:/usr/sbin')
```

{: .warning }
Don't hard-code `PATH` inside your programs, for the same reason you
wouldn't hard-code a library list: users then can't change it for
different purposes. You can still add to it for a single command, like
`PATH=$PATH:/my/dir && mycmd`, as some of the samples do.

([Klement](references.md#sources))

## Environment variables set by UNIXCMD

UNIXCMD adds these variables to the child's environment, unless your job
already sets them:

| Variable | Value | Purpose |
|---|---|---|
| `QIBM_USE_DESCRIPTOR_STDIO` | `I` | Makes ILE C stdio (which QShell uses) work with file descriptors 0, 1 and 2, which are the pipes |
| `QIBM_PASE_DESCRIPTOR_STDIO` | `T` | Makes PASE stdio use descriptors 0, 1 and 2 in *text* mode, so PASE translates between EBCDIC and ASCII |

To change their behavior, set these variables in your job before opening
the file. Your values are passed through unchanged.

## Activation groups and state

The `UNIXCMD`, `UNIXCMDOA`, `OPNPIPER4`, `SNDPIPER4`, `RCVPIPER4` and
`CLOPIPER4` programs are all built with `ACTGRP(UNIXCMD)` and bind to the
`UNIXPIPER4` service program. Everything in the service program, such as
the list of open pipes, the most recently opened pipe, and the last error,
is kept per activation group. That is why a pipe opened by `OPNPIPE` can
later be used by `SNDPIPE`, `RCVPIPE` and `CLOPIPE` in the same job.

## Authority

From the `OPNPIPE` help text:

- You need `*X` authority to every directory in the path to the command.
- A compiled executable needs `*X` authority. A shell script needs `*RX`.
- The command you run may have restrictions of its own.
- The IFS doesn't usually support adopted authority, so you can't get these
  authorities by adopting them.
