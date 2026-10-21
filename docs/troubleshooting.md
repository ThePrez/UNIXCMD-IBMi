---
title: Troubleshooting
nav_order: 10
---

# Troubleshooting
{: .no_toc }

1. TOC
{:toc}

## Start with the job log

Whenever the `UNIXPIPER4` service program records an error, it also writes
the error text to the job log as a `CPF9897` **diagnostic** message, even
when your program handles the error. Run `DSPJOBLOG` (or look at the
spooled job log of a batch job) and look for messages such as:

- `Child process ended with status 127`
- `Child process ended by signal n`
- `Attempt to read from a null pipe.`
- `Pipe has already been marked "done"`
- the text of a system error (`errno`), for example from `spawn()` or a
  pipe operation

## Test the command outside your program

Before you debug the RPG or CL, run the exact command interactively in the
same environment:

- QShell mode: `STRQSH`, then type the command.
- PASE mode: `CALL QP2TERM`, or sign on with SSH, then type the command.

If it doesn't work there, it won't work through UNIXCMD either. Be sure to
test as the **same user profile**, with the **same environment variables**
(`PATH` in particular), as the job that runs your program.

## Common problems

### The CLOSE fails (RPG status 1217, SPECIAL status 2, or CPF9897 from CLOPIPE)

The command ended with a non-zero exit status, or a signal ended it. This
is the usual way a Unix program reports failure. Look in the job log for
the exit status:

| Exit status | Usual meaning |
|---|---|
| 1 | General error reported by the program |
| 2 | Misuse of a shell command or bad arguments (varies by program) |
| 126 | The command was found but couldn't be run (often authority) |
| 127 | Command not found. Check `PATH` or use a full path. |

These are common conventions. Individual programs define their own exit
codes. To see the error text, read all the output before you close the
file. The program's stderr messages are in the records you read.

If the command was ended by a signal, one possible cause is closing the
file while the command was still writing output. See the warning in
[Return data through a file](data-handling.md#return-data-through-a-file).

### "Command not found" or exit status 127

- The program's directory isn't in the job's `PATH`. Set `PATH` (see
  [The PATH](concepts.md#the-path)), add to it on the command line
  (`PATH=$PATH:/QOpenSys/pkgs/bin && node app.js`), or use the full path.
- You may be using the wrong environment. Some programs are easier to run
  in PASE mode.

### A write fails after you've started reading

The first read closes the command's stdin, so later writes fail with RPG
status 1299 or 2, `CPE3455` from `SNDPIPE`, or `90002` from the API.
Change your program so all writes come before the first read. See
[Write first, then read](data-handling.md#write-first-then-read).

### The program hangs

- **The command is waiting for input.** Some programs don't produce output
  until stdin is closed. If you never read, use `FEOD` (or `pipe_done()`)
  to close stdin.
- **The command is waiting for a person.** Password prompts (SSH, sudo),
  "press any key" messages, and confirmation questions can't be answered
  through the pipe. Use key-based authentication and non-interactive flags
  such as `-y` or `--batch`.
- **Both sides are waiting on full pipes.** This can happen with very
  large input and output. See
  [Very large input and output](data-handling.md#very-large-input-and-output).

### Output is unreadable

The data is in the wrong character set. UNIXCMD doesn't convert data. Add
an `iconv` step to the command line, or check `QIBM_PASE_DESCRIPTOR_STDIO`.
See [Character sets](data-handling.md#character-sets-ccsids).

### Lines are cut off, or one line arrives as several records

The record (or `RCVPIPE` variable) is shorter than the line. The rest of
the line comes back on the next read. Increase the record length.

### Strange data or storage errors with a SPECIAL file

If your SPECIAL file's record length isn't 1000, pass the real length as
the third `PLIST` parameter. See [SPECIAL files](special-file.md#parameters).

### Garbage in the command, or OPEN fails, with Open Access

The `HANDLER` user area must be a fixed-length `char(5000)` field. See
[Declaring the file](open-access.md#declaring-the-file).

### Node.js (or another threaded program) won't start

Set `QIBM_MULTI_THREADED=Y` in the job before you open the file, for
example with `ADDENVVAR` or a call to `putenv()`. QShell won't start
programs that use threads without it.

### "Pipe doesn't exist." from SNDPIPE / RCVPIPE / CLOPIPE

- No pipe was opened in this activation group, or it's already been
  closed.
- You passed the wrong `PIPEID`.
- The UNIXCMD programs were compiled into different activation groups.
  `BUILDIT` puts them all in `ACTGRP(UNIXCMD)`.

### Authority errors

You need `*X` authority to every directory in the path, `*X` to compiled
programs, and `*RX` to scripts. Adopted authority usually doesn't apply in
the IFS. See [Authority](concepts.md#authority).
