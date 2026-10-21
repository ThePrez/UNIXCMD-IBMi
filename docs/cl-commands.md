---
title: CL commands
nav_order: 6
---

# Using UNIXCMD from CL
{: .no_toc }

1. TOC
{:toc}

CL doesn't support Open Access or SPECIAL files, so UNIXCMD comes with four
CL commands that do the same job:

| Command | Purpose | Like RPG's |
|---|---|---|
| `OPNPIPE` | Start a command and connect pipes to it | `OPEN` |
| `SNDPIPE` | Send one line to the command's stdin | `WRITE` |
| `RCVPIPE` | Receive one line from the command's stdout/stderr | `READ` |
| `CLOPIPE` | Close the pipes, wait for the command to end, and check its exit status | `CLOSE` |

These commands are created with `ALLOW(*IPGM *IMOD *BPGM *BMOD)`, so they
work only in CL programs and modules, not from a command line. Each one
has full prompting and help text (press F1 on the prompt).

## A complete example

This example from the presentation lists the `.zip` files in a directory
and sends each name to the user as a message:

```
PGM
   DCL VAR(&REC) TYPE(*CHAR) LEN(1000)
   DCL VAR(&EOF) TYPE(*LGL)

   OPNPIPE CMD('cd /home/sklement; ls *.zip') TYPE(*QSHELL)

   RCVPIPE RCD(&REC) EOF(&EOF)
   DOWHILE (&EOF *EQ '0')
      SNDUSRMSG MSG(&REC)
      RCVPIPE RCD(&REC) EOF(&EOF)
   ENDDO

   CLOPIPE
ENDPGM
```

([Klement](references.md#sources))

## OPNPIPE: Open Pipe & Run Unix Cmd

Starts a process in QShell or PASE and connects it to your CL program with
pipes.

| Keyword | Type | Default | Description |
|---|---|---|---|
| `CMD` | `*CHAR`, up to 5000, mixed case | *(required)* | The command line to run. It's run by a shell, so redirection, pipelines, environment variables and so on all work. |
| `TYPE` | `*QSHELL` or `*PASE` | `*QSHELL` | The environment to run the command in. `*QSHELL` works like `STRQSH`. `*PASE` works like calling `QP2SHELL` with `/QOpenSys/usr/bin/sh`. |
| `PIPEID` | `*DEC (10 0)`, return value | *(none)* | Optional. A CL variable that receives the ID of the new pipe. |

If the process can't be started, `OPNPIPE` sends `CPF9897` as an escape
message, with the system error text.

## SNDPIPE: Send Record to Unix Cmd

Sends one line of text to the command's stdin. Each `SNDPIPE` appears to
the command as a separate line.

| Keyword | Type | Default | Description |
|---|---|---|---|
| `RCD` | `*CHAR`, up to 5000, mixed case | *(required)* | The data to send. A line feed is added to it. |
| `PIPEID` | `*DEC (10 0)` | `*DFT` | The pipe to send to. `*DFT` means the most recently opened pipe. |

Escape messages: `CPF9897` if the pipe doesn't exist, and `CPE3455` if the
write fails. A write fails, for example, after `RCVPIPE` has already been
used on the pipe (see
[Write first, then read](data-handling.md#write-first-then-read)).

```
OPNPIPE CMD('cat - > /tmp/examplefile.txt')
SNDPIPE RCD('This is some silly text to put in the IFS')
CHGVAR  VAR(&DATA) VALUE('And this is line 2.')
SNDPIPE RCD(&DATA)
CLOPIPE
```

{: .note }
Unlike the RPG handlers, `SNDPIPE` doesn't trim trailing blanks. When `RCD`
is a CL variable, the command receives the whole variable, including any
trailing blanks. If those matter to the command, pass a trimmed
expression, such as `RCD(%TRIMR(&DATA))`. The CL `%TRIM` built-ins
require a release that supports them.

## RCVPIPE: Receive Record from Unix Cmd

Receives one line of output from the command.

| Keyword | Type | Default | Description |
|---|---|---|---|
| `RCD` | CL variable, `*CHAR` 1-32767 | *(required)* | Receives the line. The value is padded with blanks. A line longer than the variable is split across several `RCVPIPE`s. |
| `EOF` | CL variable, `*LGL` | *(none)* | Set to `'0'` when a line was received, or `'1'` when there's no more output |
| `PIPEID` | `*DEC (10 0)` | `*DFT` | The pipe to read from. `*DFT` means the most recently opened pipe. |

If you leave out `EOF`, `RCVPIPE` behaves like `RCVF`. At end of file it
sends `CPF0864` as an escape message, which you can catch with `MONMSG`:

```
LOOP:
   RCVPIPE RCD(&LINE)
   MONMSG CPF0864 EXEC(GOTO DONE)
   /* process &LINE */
   GOTO LOOP
DONE:
   CLOPIPE
```

## CLOPIPE: Close Pipe to Unix Cmd

Closes the pipes, waits for the process to end, and checks how it ended.

| Keyword | Type | Default | Description |
|---|---|---|---|
| `PIPEID` | `*DEC (10 0)` | `*DFT` | The pipe to close. `*DFT` means the most recently opened pipe. |

If the command ended with a non-zero exit status, was ended by a signal,
or ended with an exception, `CLOPIPE` sends `CPF9897` as an escape message
with text such as `Child process ended with status 1`.

```
CLOPIPE
MONMSG CPF9897 EXEC(DO)
   /* the Unix command reported a failure */
ENDDO
```

## Working with several pipes at once

When you leave out `PIPEID`, the commands use the most recently opened
pipe. To keep more than one process open, save each pipe's ID from
`OPNPIPE` and pass it to the other commands. This example from the
`OPNPIPE` help text deletes old `.dat` files one at a time while reading
the list from `ls`:

```
OPNPIPE CMD('cd /tmp && ls old*.dat') PIPEID(&LSPIPE)
RCVPIPE RCD(&FILENAME) EOF(&EOF) PIPEID(&LSPIPE)
DOWHILE (&EOF *EQ '0')
   OPNPIPE CMD('cd /tmp && rm' *BCAT &FILENAME) PIPEID(&RMPIPE)
   CLOPIPE PIPEID(&RMPIPE)
   RCVPIPE RCD(&FILENAME) EOF(&EOF) PIPEID(&LSPIPE)
ENDDO
CLOPIPE PIPEID(&LSPIPE)
```

## Sending and receiving data

This example from the `SNDPIPE` help text sends an address to a PHP script
and receives the latitude and longitude. `iconv` converts the EBCDIC data
from CL to ASCII for PHP. Depending on your environment, you may not need
this step. See [Character sets](data-handling.md#character-sets-ccsids).

```
OPNPIPE CMD('PATH=$PATH:/usr/local/Zend/Core/bin && +
             iconv -f 37 -t 819 | +
             php /www/zendcore/htdocs/geocode.php')
SNDPIPE RCD('1600 W Pennsylvania Av, Washington DC')
RCVPIPE RCD(&LAT)
RCVPIPE RCD(&LON)
CLOPIPE
SNDPGMMSG MSGID(CPF9897) MSGF(QCPFMSG) MSGTYPE(*DIAG) +
          MSGDTA('Lat=' *CAT &LAT *BCAT 'Lon=' *CAT &LON)
```

## Messages

| Message | Sent by | Meaning |
|---|---|---|
| `CPF9897` | All four | General UNIXCMD error. The message text has the details, for example `Pipe doesn't exist.` or `Child process ended with status n`. |
| `CPF0864` | `RCVPIPE` | End of file, sent only when `EOF` isn't specified |
| `CPE3455` | `SNDPIPE` | The write to the pipe failed |
