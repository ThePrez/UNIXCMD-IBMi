      /if defined(UNIXPIPE_H_DEFINED)
      /eof
      /endif
      /define UNIXPIPE_H_DEFINED

     /*-                                                                            +
      * Copyright (c) 2009-2016 Scott C. Klement                                    +
      * All rights reserved.                                                        +
      *                                                                             +
      * Redistribution and use in source and binary forms, with or without          +
      * modification, are permitted provided that the following conditions          +
      * are met:                                                                    +
      * 1. Redistributions of source code must retain the above copyright           +
      *    notice, this list of conditions and the following disclaimer.            +
      * 2. Redistributions in binary form must reproduce the above copyright        +
      *    notice, this list of conditions and the following disclaimer in the      +
      *    documentation and/or other materials provided with the distribution.     +
      *                                                                             +
      * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND      +
      * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE       +
      * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE  +
      * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE     +
      * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL  +
      * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS     +
      * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)       +
      * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT  +
      * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY   +
      * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF      +
      * SUCH DAMAGE.                                                                +
      *                                                                             +
      */                                                                            +

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * pipe_open(): Start a Unix process and connect pipes to it
      *
      *   cmd = (input) Unix command-line to run.
      *  type = (input/optional) Indicates the environment/shell
      *                 that should run the command.
      *            Q = QShell -- this is default.
      *            P = PASE, using Bourne Shell
      *          ' ' = Raw. (Provide path to shell executable)
      *
      * Returns a pointer to a DS that represents the current
      *         connection state.
      *   or *NULL if there's an error.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D pipe_open       pr              *
     D   cmd                      65535a   varying const options(*varsize)
     D   type                         1a   const options(*nopass:*omit)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * pipe_close():  Disconnect pipe and wait for unix process
      *                to end.
      *
      *       pip = (inp/out) connection to close
      *
      *  exitType = (optional) returns how the Unix process ended
      *             PIPE_NORMAL  = ended normally
      *             PIPE_SIGNAL  = process ended by a signal
      *             PIPE_STOPPED = process was suspended by signal
      *             PIPE_EXCP    = process ended by an exception
      *
      *  exitCode = (optional) this is the exit status, signal
      *                   number, or exception used when the
      *                   process ended.
      *
      *  Returns 0 if the process reported no errors
      *      or -1 if an error occurred (including exit status > 0)
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D pipe_close      pr            10i 0
     D   pip                           *   value
     D   exitType                     5u 0 options(*nopass:*omit)
     D   exitCode                     5u 0 options(*nopass:*omit)

     D PIPE_NORMAL     C                   0
     D PIPE_SIGNAL     C                   2
     D PIPE_STOPPED    C                   4
     D PIPE_EXCP       C                   4


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * pipe_read(): Read data from the pipe that's connected
      *              to STDOUT/STDERR on the Unix process
      *
      *   pip = (input) connection to read from
      *  line = (output) one line of text read from the process
      *
      *  Returns the length of the line read, or -1 upon failure
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D pipe_read       pr            10i 0 opdesc
     D   pip                           *   value
     D   line                     65535a   varying options(*varsize)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * pipe_readb(): Read data from the pipe that's connected
      *               to STDOUT/STDERR on the Unix process
      *               into a memory buffer
      *
      *   pip = (input) connection to read from
      *   buf = (output) buffer to read data into
      *  size = (input)  size of buffer
      *
      *  Returns the length of the line read, or -1 upon failure
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D pipe_readb      pr            10i 0
     D   pip                           *   value
     D   buf                           *   value
     D   size                        10u 0 value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * pipe_readf(): Read data from the pipe that's connected
      *               to STDOUT/STDERR on the Unix process into
      *               a fixed-length alphanumeric field
      *
      *   pip = (input) connection to read from
      *  line = (output) one line of text read from the process
      *
      *  Returns the length of the line read, or -1 upon failure
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D pipe_readf      pr            10i 0 opdesc
     D   pip                           *   value
     D   line                     65535a   options(*varsize)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * pipe_write(): Write data to the pipe connected to the STDIN
      *               of the Unix process
      *
      *  NOTE: It is assumed that you will do all of your writing
      *        before you read from the pipe.  Therefore, this
      *        routine will *only* function before the first call
      *        to pipe_read().
      *
      *   pip = (input) connection to write to
      *  line = (input) line of text to write.  An EOL will be
      *                 appended to this string while writing to
      *                 the pipe.
      *
      * returns the length written, or -1 upon failure
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D pipe_write      pr            10i 0
     D   pip                           *   value
     D   line                     65535a   varying const options(*varsize)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * pipe_writef(): Write data from a fixed-length alphanumeric
      *                field to the STDIN of the Unix process
      *
      *  NOTE: It is assumed that you will do all of your writing
      *        before you read from the pipe.  Therefore, this
      *        routine will *only* function before the first call
      *        to pipe_read().
      *
      *   pip = (input) connection to write to
      *  line = (input) line of text to write.  An EOL will be
      *                 appended to this string while writing to
      *                 the pipe.
      *
      * returns the length written, or -1 upon failure
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D pipe_writef     pr            10i 0 opdesc
     D   pip                           *   value
     D   line                     65535a   const options(*varsize)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * pipe_writeb(): Write data to the pipe connected to the STDIN
      *               of the Unix process from a memory buffer
      *
      *  NOTE: It is assumed that you will do all of your writing
      *        before you read from the pipe.  Therefore, this
      *        routine will *only* function before the first call
      *        to pipe_read().
      *
      *   pip = (input) connection to write to
      *   buf = (input) buffer to write data from
      *   len = (input) length of data to write
      *
      * returns the length written, or -1 upon failure
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D pipe_writeb     pr            10i 0
     D   pip                           *   value
     D   buf                           *   value
     D   len                         10u 0 value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * pipe_done():  Tell the Unix process that you are done
      *               writing data.
      *
      *  NOTE: This closes the pipe that's connected to the STDIN
      *        of the unix process, without closing the STDOUT pipe
      *        or stopping the process.
      *
      * Failure is not an option. (always succeeds)
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D pipe_done       pr
     D   pip                           *   value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * pipe_setEol(): Set the end-of-line (EOL) character(s) used
      *                for this session.
      *
      *  NOTE: If you do not call this, the default EOL character
      *        is x'25' (linefeed). (This is the normal character
      *        used by Unix software.)
      *
      *        For example, if you wanted to use the Windows
      *        convention of CRLF, you could code
      *
      *            pipe_setEol(myp: x'0d25');
      *
      *    pip = (input) connection to set chars for
      * newEol = (input) the new EOL characters to use.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D pipe_setEol     pr
     D   pip                           *   value
     D   newEol                       2a   varying const


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * pipe_error():  Return info about the last error that
      *                occurred in this module
      *
      *   errnum = (output/optional) error number identifying the
      *                error that last occurred.
      *
      *  returns a message identifying the last error
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D pipe_error      pr            80a   varying
     D   errnum                      10i 0 options(*omit:*nopass)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * pipe_getId(): Get the pipe id number for a pipe
      *
      *   pip = (input) the pipe's child handle
      *                 (as returned by pipe_open)
      *
      * returns the pipeid number, or -1 upon error
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D pipe_getId      pr            10i 0
     D   pip                           *   value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * pipe_getHandle(): Get the child handle for a given pipeid
      *
      *   pipeid = (input) the pipeid to find the handle for
      *
      * returns the handle, or *null if it's not found
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D pipe_getHandle  pr              *
     D   pipeid                      10i 0 value
