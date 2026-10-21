---
title: Home
layout: home
nav_order: 1
---

# UNIXCMD for IBM i

UNIXCMD lets RPG and CL programs on IBM i run Unix-style programs (QShell
utilities, PASE programs, shell scripts, Python, Node.js, PHP, Perl, Java,
SSH, and so on) and talk to them as they run. Your program writes to the
command's **standard input** and reads its **standard output** as if it were
an ordinary file.

```rpgle
**FREE
dcl-f UNIX disk(1000) handler('UNIXCMDOA': cmd) usropn;
dcl-s cmd char(5000);
dcl-ds record len(1000) end-ds;

cmd = 'cd /tmp; ls';
open UNIX;

read UNIX record;
dow not %eof(UNIX);
   // each READ returns one line of output from "ls"
   read UNIX record;
enddo;

close UNIX;
```

## Why UNIXCMD?

IBM i programs usually call each other by passing parameters by reference,
and the called program can change them to return results. Programs in the
PASE / Unix-like environment work differently:

- They run in **their own process**, not as a new entry in your call stack.
- Their parameters are **input-only** and fairly **short**.
- They take input from **standard input (stdin)** and send results to
  **standard output (stdout)**. Both streams can be any length.
- They write error messages to **standard error (stderr)** and report
  success or failure with an **exit status** from 0 to 255.

The `QSH CMD(...)` command can start such a program, but it can't feed data
to the program's stdin, it can't easily process the output, and you get no
output until the program has finished. UNIXCMD fixes all three problems by
connecting your program to the command with *pipes*.
([Klement, *UNIXCMD: Integrating RPG with Open Source*](references.md#sources))

## Four ways to use it

| Interface | Use it from | Object | Guide |
|---|---|---|---|
| RPG Open Access handler | RPG (IBM i 7.1 and later, with Open Access support) | `UNIXCMDOA` program | [Open Access](open-access.md) |
| RPG SPECIAL file handler | RPG (any release, fixed or free format) | `UNIXCMD` program | [SPECIAL files](special-file.md) |
| CL commands | CL programs | `OPNPIPE`, `SNDPIPE`, `RCVPIPE`, `CLOPIPE` | [CL commands](cl-commands.md) |
| Procedure API | Any ILE language | `UNIXPIPER4` service program | [API reference](api.md) |

All four use the same engine: the `UNIXPIPER4` service program.

## Where to start

1. Read [Concepts](concepts.md) to see how UNIXCMD starts and talks to a
   Unix process.
2. [Install and build](installation.md) UNIXCMD on your system.
3. Pick an interface from the table above.
4. Read [Working with data](data-handling.md) to understand records, line
   endings, character sets, and the "write first, then read" rule.
5. Look through the [sample programs](examples.md), and keep
   [Troubleshooting](troubleshooting.md) handy.

## License

UNIXCMD is Copyright &copy; 2009-2016 Scott C. Klement and is distributed
under a BSD-style license. The full text is at the top of each source file.
