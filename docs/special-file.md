---
title: RPG SPECIAL files
nav_order: 5
---

# Using UNIXCMD with RPG SPECIAL files
{: .no_toc }

1. TOC
{:toc}

The `UNIXCMD` program is a handler for the RPG `SPECIAL` device. A
`SPECIAL` file calls a program you name for every file operation. RPG has
supported `SPECIAL` files for a long time, so this interface works on
releases without Open Access and in fixed-format code.

## Declaring the file

### Fixed format

```rpgle
     FUNIX      CF   F 1000        SPECIAL PGMNAME('UNIXCMD')
     F                                     PLIST(UNIXPARM) USROPN

     D cmd             s           5000a

     C     UNIXPARM      PLIST
     C                   PARM                    CMD
```

### Free-format declaration (7.1 and later)

A `PLIST` still needs a fixed-format C-spec:

```rpgle
        dcl-f UNIX special(1000) pgmname('UNIXCMD') plist(unixparm) usropn;
        dcl-s cmd char(5000);

     C     UNIXPARM      PLIST
     C                   PARM                    cmd
```

The file type decides which operations are allowed:

| File type | Use |
|---|---|
| `IF` | Read only, to process the command's output |
| `O` | Write only, to send data to the command's input |
| `CF` / `UF` | Read and write |

## Parameters

RPG always passes the first four parameters (option, status, error code,
and record area) to a SPECIAL file program. The parameters in your
`PLIST` are added after them. `UNIXCMD` accepts up to three:

| # | `PLIST` parameter | Type | Required | Meaning |
|---|---|---|---|---|
| 1 | Command | `char(5000)` | Yes | The command line to run |
| 2 | Environment | `char(1)` | No | `Q` for QShell (the default) or `P` for PASE. A blank also means QShell. |
| 3 | Record length | `packed(5:0)` | No | The record length of the file. **The default is 1000.** |

{: .warning }
A SPECIAL file handler can't find out your file's record length, so
`UNIXCMD` assumes 1000. If your file's record length isn't 1000, pass the
real length as the third `PLIST` parameter. If you don't, a read or write
can use more storage than your record has.

```rpgle
     FUNIX      IF   F  256        SPECIAL PGMNAME('UNIXCMD')
     F                                     PLIST(UNIXPARM) USROPN
     D cmd             s           5000a
     D mode            s              1a   inz('Q')
     D reclen          s              5p 0 inz(256)

     C     UNIXPARM      PLIST
     C                   PARM                    CMD
     C                   PARM                    MODE
     C                   PARM                    RECLEN
```

Raw mode isn't available through the SPECIAL file interface, because a
blank environment means QShell. Use [Open Access](open-access.md) with the
`raw:` prefix, or the [API](api.md), if you need raw mode.

## Operations

| RPG operation | What `UNIXCMD` does |
|---|---|
| `OPEN` | Starts the command |
| `WRITE` / `UPDATE` / `EXCEPT` | Trims trailing blanks from the record, adds a line feed, and writes the result to stdin |
| `READ` | Reads one line of stdout/stderr. `%EOF` is set on when there's no more output. |
| `FEOD` | Closes the command's stdin |
| `CLOSE` | Closes the pipes, waits for the command to end, and checks the exit status |

## Status and error codes

`UNIXCMD` returns a status to RPG for each operation: `0` for success, `1`
for end of file, `2` for an error. On an error, the error code parameter
contains one of these values:

| Error code | Meaning |
|---|---|
| `errno` value | `OPEN` or `WRITE` failed. This is the system error number. |
| Exit status | `CLOSE` found that the command ended with a non-zero exit status or because of a signal. This is the exit status or signal number. |
| `88888` | An operation was attempted while no command is running |
| `99999` | The operation isn't supported |

RPG turns a status of `2` into a file exception, which you can handle with
`(E)`, `MONITOR`, `INFSR` or `*PSSR`.

## Example: reading output (fixed format)

This is `EXAMPLE1`. It lists `/tmp` to a spooled file using input specs and
`EXCEPT` output:

```rpgle
     FUNIX      CF   F 1000        SPECIAL PGMNAME('UNIXCMD')
     F                                     PLIST(UNIXPARM) USROPN
     FQSYSPRT   O    F  132        PRINTER

     D cmd             s           5000a
     D record          s           1000a
     D outrec          s            132a

     IUNIX      NS
     I                                  1 1000  Record

     C     UNIXPARM      PLIST
     C                   PARM                    CMD
      /free
          cmd = 'cd /tmp; ls';
          open UNIX;

          read UNIX;
          dow not %eof(UNIX);
             outrec = record;
             except;
             read UNIX;
          enddo;

          *inlr = *on;
      /end-free

     OQSYSPRT   E
     O                       outrec             132
```

`EXAMPLE4` does the same thing, but reads into a data structure
(`read UNIX record;`), so it needs no input specs.

## Example: writing to a command (output only)

This is `EXAMPLE2`. It uses `cat - > /tmp/myfile.txt` to write two lines
to an IFS file:

```rpgle
     FUNIX      O    F 1000        SPECIAL PGMNAME('UNIXCMD')
     F                                     PLIST(UNIXPARM) USROPN

     D cmd             s           5000a

     C     UNIXPARM      PLIST
     C                   PARM                    CMD
      /free
          cmd = 'cat - > /tmp/myfile.txt';
          open UNIX;

          except writeToIfs;
          close UNIX;

          *inlr = *on;
      /end-free

     OUNIX      E            writeToIfs
     O                                              'This is some silly -
     O                                              text to put in the IFS'
     O          E            writeToIfs
     O                                              'And this is line 2.'
```

## Example: choosing PASE

This is `EXAMPLE5`. It passes a second `PLIST` parameter with the value
`P`, so the command runs in PASE:

```rpgle
     D cmd             s           5000a
     D mode            s              1A   inz('P')

     C     UNIXPARM      PLIST
     C                   PARM                    CMD
     C                   PARM                    MODE
```

`EXAMPLE6` uses the same setup to run a command on another server over
SSH:

```rpgle
          cmd = 'ssh bcserv3.klements.com ps axww "|" +
                 grep boxrelay "|" grep -v grep';
```

The `"|"` characters are quoted so the local shell passes them to `ssh`
instead of building the pipeline locally. As a result, `grep` runs on the
remote server. This only works if non-interactive (key-based) SSH sign-on
is already set up for the user running the program.

## Example: sending input and reading output

This is `EXAMPLE7`. It sends an address to a PHP script and reads back the
latitude and longitude. See [Examples](examples.md#example7-php-integration)
for the full program.

```rpgle
          cmd = 'PATH=$PATH:/usr/local/ZendSvr6/bin && +
                iconv -f 37 -t 819 | +
                php-cli /www/zendsvr/htdocs/geocode.php';
          open UNIX;

          record = '1600 W Pennsylvania Av, Washington DC';
          write UNIX record;

          read UNIX record;
          lat = %dec(record: 11: 7);

          read UNIX record;
          lon = %dec(record: 11: 7);

          close UNIX;
```
