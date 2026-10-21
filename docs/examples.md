---
title: Sample programs
nav_order: 9
---

# Sample programs
{: .no_toc }

The sample programs are in
[`samples/rpg`](https://github.com/ThePrez/UNIXCMD-IBMi/tree/main/samples/rpg).
`BUILDIT` compiles them into your current library as `EXAMPLE1` through
`EXAMPLE11`.

1. TOC
{:toc}

## Overview

| Sample | Interface | Format | Demonstrates |
|---|---|---|---|
| [EXAMPLE1](#example1-list-a-directory) | SPECIAL | Fixed | Read command output with input specs and print it |
| [EXAMPLE2](#example2-write-to-an-ifs-file) | SPECIAL | Fixed | Write-only file: send lines to `cat` to create an IFS file |
| [EXAMPLE3](#example3-convert-ascii-to-ebcdic) | SPECIAL | Fixed | Write, then read: convert ASCII to EBCDIC with `iconv` |
| [EXAMPLE4](#example4-read-into-a-data-structure) | SPECIAL | Fixed | Like EXAMPLE1, but reads into a data structure |
| [EXAMPLE5](#example5-run-in-pase) | SPECIAL | Fixed | Choose PASE mode with a second `PLIST` parameter |
| [EXAMPLE6](#example6-remote-command-over-ssh) | SPECIAL | Fixed | Run a command on another system over SSH |
| [EXAMPLE7](#example7-php-integration) | SPECIAL | Fixed | Send input to a PHP script and read structured output |
| [EXAMPLE8](#example8-free-format-special-file) | SPECIAL | Free (`DCL-F`) | EXAMPLE4 with a free-format declaration |
| [EXAMPLE9](#example9-open-access) | Open Access | `**FREE` | EXAMPLE1 using `UNIXCMDOA` |
| [EXAMPLE10](#example10-open-access-write-then-read) | Open Access | `**FREE` | EXAMPLE3 using `UNIXCMDOA` |
| [EXAMPLE11](#example11-open-access-in-pase-mode) | Open Access | `**FREE` | EXAMPLE5 using the `pase:` prefix |

## EXAMPLE1: list a directory

[Source](https://github.com/ThePrez/UNIXCMD-IBMi/blob/main/samples/rpg/example1.rpgle)

Runs `cd /tmp; ls` in QShell, reads each line of output through input
specs, and prints it to `QSYSPRT` with `EXCEPT`. The file isn't closed
explicitly. It's closed when `*INLR` ends the program.

```rpgle
          cmd = 'cd /tmp; ls';
          open UNIX;

          read UNIX;
          dow not %eof(UNIX);
             outrec = record;
             except;
             read UNIX;
          enddo;
```

## EXAMPLE2: write to an IFS file

[Source](https://github.com/ThePrez/UNIXCMD-IBMi/blob/main/samples/rpg/example2.rpgle)

An output-only (`O`) SPECIAL file. `cat - > /tmp/myfile.txt` copies its
stdin to an IFS file, so each `EXCEPT` record becomes one line of the file.
The `CLOSE` closes stdin, which lets `cat` finish.

```rpgle
          cmd = 'cat - > /tmp/myfile.txt';
          open UNIX;

          except writeToIfs;
          close UNIX;
```

## EXAMPLE3: convert ASCII to EBCDIC

[Source](https://github.com/ThePrez/UNIXCMD-IBMi/blob/main/samples/rpg/example3.rpgle)

Writes the ASCII bytes for "Hello" (`x'48656c6c6f'`) to
`iconv -f 819 -t 0`, which converts them from ASCII to the job's CCSID.
Then it reads the result back and displays it. This sample shows the
[write first, then read](data-handling.md#write-first-then-read) pattern,
and also shows that UNIXCMD itself doesn't convert data.

```rpgle
     D AsciiData       c                   x'48656c6c6f'
      ...
          cmd = 'iconv -f 819 -t 0';
          open UNIX;

          except writeAscii;
          read UNIX;
          dsply (%subst(record:1:5));
```

## EXAMPLE4: read into a data structure

[Source](https://github.com/ThePrez/UNIXCMD-IBMi/blob/main/samples/rpg/example4.rpgle)

The same as EXAMPLE1, but it reads into a 1000-byte data structure with
`read UNIX record;` and writes a 132-byte data structure to the printer,
so no input or output specs are needed.

## EXAMPLE5: run in PASE

[Source](https://github.com/ThePrez/UNIXCMD-IBMi/blob/main/samples/rpg/example5.rpgle)

The same as EXAMPLE4, with a second `PLIST` parameter set to `'P'` so the
command runs in PASE (`/QOpenSys/usr/bin/sh`) instead of QShell.

```rpgle
     D mode            s              1A   inz('P')

     C     UNIXPARM      PLIST
     C                   PARM                    CMD
     C                   PARM                    MODE
```

## EXAMPLE6: remote command over SSH

[Source](https://github.com/ThePrez/UNIXCMD-IBMi/blob/main/samples/rpg/example6.rpgle)

Runs `ps` and `grep` on a remote server through `ssh` (in PASE mode), and
prints the result. The pipe characters are quoted (`"|"`) so they're
passed to the remote shell instead of being handled locally.

```rpgle
          cmd = 'ssh bcserv3.klements.com ps axww "|" +
                 grep boxrelay "|" grep -v grep';
```

To run this sample, change the host name and command, and set up
key-based SSH authentication for the user running the program. A
password prompt can't be answered through the pipe.

## EXAMPLE7: PHP integration

[Source](https://github.com/ThePrez/UNIXCMD-IBMi/blob/main/samples/rpg/example7.rpgle) ·
[geocode.php](https://github.com/ThePrez/UNIXCMD-IBMi/blob/main/samples/php_geocode/geocode.php)

Sends a street address to a PHP script, which geocodes it and prints the
latitude and longitude on two lines. The command line:

1. adds the Zend Server PHP `bin` directory to `PATH`,
2. converts the input from EBCDIC (CCSID 37) to ASCII (819) with `iconv`,
   and
3. pipes the converted input into `php-cli`.

```rpgle
     FUNIX      CF   F 1000        SPECIAL PGMNAME('UNIXCMD')
     F                                     PLIST(UNIXPARM) USROPN

     D cmd             s           5000a
     D record          ds          1000
     D lat             s             11p 7
     D lon             s             11p 7

     C     UNIXPARM      PLIST
     C                   PARM                    CMD
      /free
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

          dsply ('lat=' + %char(lat));
          dsply ('lon=' + %char(lon));
          *inlr = *on;
      /end-free
```

The PHP side reads one line from stdin and writes two lines to stdout:

```php
<?php
    $address = fgets(STDIN);
    $wsdl = 'http://geocoder.us/dist/eg/clients/GeoCoderPHP.wsdl';
    $client = new SoapClient($wsdl);
    $result = $client->geocode($address);
    echo $result[0]->lat . "\n";
    echo $result[0]->long . "\n";
?>
```

{: .note }
The paths in this sample (`/usr/local/ZendSvr6`, `/www/zendsvr`) and the
geocoding web service it calls come from an older environment and may no
longer exist. The pattern is what matters: a script that reads stdin and
writes stdout works the same way in any language. The
[Node.js geocode example](open-access.md#example-a-nodejs-program-with-structured-replies)
shows the same idea with a current toolset.

## EXAMPLE8: free-format SPECIAL file

[Source](https://github.com/ThePrez/UNIXCMD-IBMi/blob/main/samples/rpg/example8.rpgle)

EXAMPLE4 with a free-format declaration. The `PLIST` still needs C-specs.

```rpgle
        dcl-f UNIX special(1000) pgmname('UNIXCMD') plist(unixparm) usropn;
        dcl-f QSYSPRT printer(132) usage(*output);
        dcl-s cmd char(5000);
        dcl-ds record len(1000) end-ds;
        dcl-ds outrec len(132) end-ds;

     C     UNIXPARM      PLIST
     C                   PARM                    cmd
```

## EXAMPLE9: Open Access

[Source](https://github.com/ThePrez/UNIXCMD-IBMi/blob/main/samples/rpg/example9.rpgle)

EXAMPLE1 written in fully free format, using the `UNIXCMDOA` Open Access
handler. The command is passed as the handler's user area.

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

## EXAMPLE10: Open Access, write then read

[Source](https://github.com/ThePrez/UNIXCMD-IBMi/blob/main/samples/rpg/example10.rpgle)

EXAMPLE3 written with Open Access. The record length is 5, and `cmd` is
set with `inz`, so the file can be opened automatically without `usropn`.

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

## EXAMPLE11: Open Access in PASE mode

[Source](https://github.com/ThePrez/UNIXCMD-IBMi/blob/main/samples/rpg/example11.rpgle)

EXAMPLE5 written with Open Access. It chooses PASE by starting the command
with the `pase:` prefix:

```rpgle
cmd = 'pase:cd /tmp; ls';
```

The comments in the sample list all the prefixes: `pase:`, `qsh:` (or
`qshell:`), and `raw:`. The default is QShell.
