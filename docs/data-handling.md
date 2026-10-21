---
title: Working with data
nav_order: 7
---

# Working with data
{: .no_toc }

1. TOC
{:toc}

## Records are lines

Data passes through the pipes as plain bytes, but UNIXCMD presents it to
your program as **lines of text**:

- **Writing** sends the record (trailing blanks trimmed, in the RPG
  handlers) followed by an end-of-line character, so each `WRITE` or
  `SNDPIPE` is one line to the command.
- **Reading** returns everything up to the next end-of-line character. The
  end-of-line character is removed, and the rest of the record is filled
  with blanks.

The default end-of-line character is `x'25'`, the EBCDIC line feed. This
is the Unix convention, translated into EBCDIC. When you use the
[API](api.md), you can change it for a pipe with `pipe_setEol()`. For
example, `pipe_setEol(p: x'0d25')` uses CR+LF.

### Long lines

If a line is longer than your record (or `RCVPIPE` variable), the first
part fills the record, and the **rest of the line is returned by the next
read**. You don't lose any data, but a single logical line arrives as
several records. To avoid this, make the record longer than the longest
line you expect. The samples use 1000.

### Writes are limited to one record

Each write sends at most one record's worth of data. To send more, write
several lines. Most Unix programs that read stdin handle many lines
without trouble.

## Write first, then read

{: .important }
The first time you read from a pipe, UNIXCMD closes the command's
standard input. After that, writes fail (RPG status 1299 or 2, or
`CPE3455` from `SNDPIPE`).

UNIXCMD is designed for this sequence:

1. Open
2. Write **all** the input
3. Read **all** the output
4. Close

Closing stdin is how a Unix program learns there's no more input. Many
programs, such as `cat`, `sort` and `iconv`, and scripts that read until
end of file, don't produce output or finish until stdin is closed.
Closing it automatically on the first read means these programs work
without any extra code.

To close stdin explicitly without reading, use the RPG `FEOD` operation
(or `pipe_done()` in the API). This helps when the command writes all its
results to a file instead of to stdout.

### Very large input and output

Pipes hold only a limited amount of data. Suppose you write a lot of input
to a command that writes output *while it's still reading*. The command
can fill the output pipe and stop to wait for you to read it, while you're
stopped waiting for it to accept more input. To avoid this, send large
amounts of input through a file instead, or use a command that reads all
its input before it writes anything.

## Character sets (CCSIDs)

UNIXCMD itself **does not convert any data**. It sends exactly the bytes
in your record and returns exactly the bytes the command writes. Whether
those bytes are EBCDIC or ASCII depends on the command and the environment:

- **QShell utilities** (`ls`, `cat`, `cd`, `echo`, and so on) work in your
  job's EBCDIC CCSID, so text normally passes through without problems.
- **PASE programs** work in ASCII. UNIXCMD sets
  `QIBM_PASE_DESCRIPTOR_STDIO=T` (unless you set it yourself), which asks
  PASE to translate the standard streams between EBCDIC and ASCII. In many
  setups that's enough.
- Sometimes you still need to convert the data yourself. You can do it
  inside the command line with `iconv`.

`EXAMPLE7` converts its input from EBCDIC to ASCII before PHP reads it:

```
iconv -f 37 -t 819 | php-cli /www/zendsvr/htdocs/geocode.php
```

`EXAMPLE3` and `EXAMPLE10` do the opposite. They send ASCII bytes to
`iconv`, which converts them to the job's CCSID (`-t 0`):

```rpgle
cmd = 'iconv -f 819 -t 0';
```

Whether you need `iconv`, and in which direction, depends on your release,
your job CCSID, and the program you're running. Test with simple data
first.

## Data structures and numbers

Each record is just bytes, so you can use any character data structure as
the record. Use **character** fields for data that goes to or comes from
the command. Unix programs read and write text, not packed or binary
numbers. Convert numbers with `%CHAR` / `%EDITC` before writing, and with
`%DEC` / `%INT` after reading:

```rpgle
read UNIX record;
lat = %dec(record: 11: 7);
```

To return several values, have the command print one value per line and
read them in order. `EXAMPLE7` reads the latitude and then the longitude.

## Detecting errors in the output

Standard error is merged into standard output, so error messages look like
normal output records. Here are some ways to tell them apart:

- **Check the exit status.** `CLOSE` / `CLOPIPE` fails when the command
  ends with a non-zero status. This is the most reliable check.
- **Tag each record.** If you write the script, start each line with a
  type. In the presentation's geocode example, the script writes
  `err <message>` for errors, and the RPG program checks the first three
  characters:

  ```rpgle
  dcl-ds record qualified;
    type char(3);
    *n   char(1);
    data char(996);
  end-ds;

  read UNIX record;
  if record.type = 'err';
     // handle the error
  endif;
  ```

- **Redirect stderr in the command.** Add `2>/dev/null` to throw error
  messages away, or `2>/tmp/myerr.log` to keep them in a file.

## Return data through a file

For output that is very large, or that isn't text, you can write the data
to a file and use UNIXCMD only to run the command and check its exit
status:

```rpgle
cmd = 'cd /home/me/reports && python3 build.py > /tmp/report.csv 2> /tmp/report.err';
open UNIX;
close UNIX;    // fails if build.py exits with a non-zero status
```

Then read the file with your usual IFS tools.

{: .warning }
`CLOSE` closes the read end of the output pipe *before* it waits for the
command to end. If the command is still writing to stdout or stderr at
that point, it can be ended by a `SIGPIPE` signal, and the `CLOSE` then
fails. Either read all the output before closing, or redirect both
streams, as shown above.
