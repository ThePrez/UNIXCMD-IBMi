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

      * UNIXPIPER4:  This is a service program for spawning unix child
      *              jobs connected to the local job's pipes, and tools
      *              for reading/writing those pipes.
      *
      *                                    Scott Klement, Sept 17, 2009
      *
      * To compile:
      *>      CRTRPGMOD unixpiper4 SRCFILE(QRPGLESRC) DBGVIEW(*LIST)
      *>      CRTSRVPGM unixpiper4 EXPORT(*ALL) BNDDIR(QC2LE)
      *> ign: DLTMOD unixpiper4
      *

     H NOMAIN OPTION(*SRCSTMT) BNDDIR('QC2LE')
     H COPYRIGHT('UNIXCMD 1.3 Copyright (c) 2010-2016 Scott C. Klement')

      /copy spawn_h
      /copy unixpipe_h
      /copy ifsio_h

     D CEEGSI          pr
     D   posn                        10i 0 const
     D   type                        10i 0
     D   curlen                      10i 0
     D   maxlen                      10i 0

     D memset          pr              *   extproc(*CWIDEN:'memset')
     D   buf                           *   value
     D   char                        10i 0 value
     D   len                         10u 0 value

     D memcpy          pr              *   extproc(*CWIDEN:'memcpy')
     D   dst                           *   value
     D   src                           *   value
     D   len                         10u 0 value

     D writebCheat     pr            10i 0 extproc('PIPE_WRITEB')
     D   pip                           *   value
     D   buf                      65535a   const options(*varsize)
     D   len                         10u 0 value

     D environ         s               *   import('environ')
     D envp            s               *   dim(32767)
     D                                     based(environ)

     D LF              c                   x'25'
     D VARPREF         c                   2

     D ReportError     PR
     D   msgno                       10i 0 value
     D   msg                         80a   varying const

     D last            ds                  qualified
     D   msgno                       10i 0
     D   msg                         80a   varying inz('')

     D lastPipe        s               *   inz(*null)
     D pipeList        s               *   dim(1000) inz(*null)

     D child_t         ds                  qualified
     D   pid                         10i 0 inz(-1)
     D   pipe0                       10i 0 inz(-1)
     D   pipe1                       10i 0 inz(-1)
     D   p1str                       10i 0 inz(1)
     D   eol                          2a   varying inz(LF)
     D   p1buf                    32768a   varying inz('')


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
     P pipe_open       B                   export
     D pipe_open       pi              *
     D   cmd                      65535a   varying const options(*varsize)
     D   type                         1a   const options(*nopass:*omit)

     d qp0zPipe        PR            10I 0 ExtProc('Qp0zPipe')
     d   fildes                      10I 0 dim(2)
     D close           PR            10I 0 ExtProc('close')
     D  fildes                       10I 0 value
     D getenv          PR              *   extproc('getenv')
     D   envvar                        *   value options(*string)

     D myType          s              1a   inz('Q')
     D usefd           s            100a
     D usepasefd       s            100a
     D env             s               *   dim(32767)

     D pipe0           s             10i 0 dim(2)
     D pipe1           s             10i 0 dim(2)

     D retval          ds                  likeds(child_t)
     D                                     based(p_retval)

     D arg             s          65535a   dim(4)
     D argv            s               *   dim(5)
     D argc            s             10i 0
     D map             s             10i 0 dim(3)
     D x               s             10i 0
     D y               s             10i 0 inz(0)
     D inh             ds                  likeds(inheritance_t)
     D pid             s             10i 0

      /free
         if %parms >= 2 and %addr(type)<>*null;
            myType = type;
         endif;

         // --------------------------------------------------------
         //   Create pipes and map them to the stdin, stdout, stderr
         //   of the spawned child job.
         // --------------------------------------------------------

         if qp0zPipe(pipe0) = -1;
            ReportError(-1: ' ');
            return *null;
         endif;

         if qp0zPipe(pipe1) = -1;
            ReportError(-1: ' ');
            return *null;
         endif;

         map(1) = pipe0(1);
         map(2) = pipe1(2);
         map(3) = pipe1(2);

         // --------------------------------------------------------
         //  Copy environment variables to spawned job.
         //  also set QIBM_USE_DESCRIPTOR_STDIO if it's not already!
         // --------------------------------------------------------

         env(*) = *null;
         if getenv('QIBM_USE_DESCRIPTOR_STDIO') = *null;
            y += 1;
            usefd = 'QIBM_USE_DESCRIPTOR_STDIO=I' + X'00';
            env(y) = %addr(usefd);
         endif;
         if getenv('QIBM_PASE_DESCRIPTOR_STDIO') = *null;
            y += 1;
            usepasefd = 'QIBM_PASE_DESCRIPTOR_STDIO=T' + X'00';
            env(y) = %addr(usepasefd);
         endif;

         x=1;
         dow envp(x) <> *null;
           y += 1;
           env(y) = envp(x);
           x += 1;
         enddo;

         // --------------------------------------------------------
         //   Build parameter list for spawned job.
         // --------------------------------------------------------

         argv(*) = *null;
         select;
         when myType = 'Q';
           arg(1) = '/qsys.lib/qshell.lib/qzshsh.pgm' + x'00';
           arg(2) = '-c' + x'00';
           arg(3) = cmd + x'00';
           argc   = 3;
         when myType = 'P';
           arg(1) = '/qsys.lib/qp2shell.pgm' + x'00';
           arg(2) = '/qopensys/usr/bin/sh' + x'00';
           arg(3) = '-c' + x'00';
           arg(4) = cmd + x'00';
           argc   = 4;
         other;
           arg(1) = cmd + x'00';
           argc   = 1;
         endsl;

         for x = 1 to argc;
           argv(x) = %addr(arg(x));
         endfor;

         // --------------------------------------------------------
         //   Spawn the child job. Close the ends of the pipes
         //   that are not used on this side of the connection.
         // --------------------------------------------------------

         inh = *ALLx'00';
         pid = spawn( argv(1): 3: map: inh: argv: env );

         callp close(pipe0(1));
         callp close(pipe1(2));

         if pid = -1;
            callp close(pipe0(2));
            callp close(pipe1(1));
            ReportError(-1: ' ');
            return *null;
         endif;

         // --------------------------------------------------------
         //   Allocate & build a data structure to track state info
         //   for the spawned job.  Return it.
         // --------------------------------------------------------

         p_retval = %alloc(%size(retval));
         retval = child_t;
         retval.pid = pid;
         retval.pipe0 = pipe0(2);
         retval.pipe1 = pipe1(1);

         if (retval.pipe1 <= %elem(pipeList));
            pipeList(retval.pipe1) = p_retval;
         endif;

         lastPipe = p_retVal;
         return p_retval;
      /end-free
     P                 E


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
     P pipe_close      B                   export
     D pipe_close      pi            10i 0
     D   pip                           *   value
     D   exitType                     5u 0 options(*nopass:*omit)
     D   exitCode                     5u 0 options(*nopass:*omit)

     D chd             ds                  likeds(child_t)
     D                                     based(pip)
     D rc              s             10i 0
     D pid             s             10i 0

     D sts             ds                  qualified
     D   code                        10i 0
     D   type                         5u 0 overlay(code:1)
     D   fail                         5u 0 overlay(code:3)

      /free
         if pip = *null;
            return 0;
         endif;

        // ---------------------------------------------
        //   Close STDIN and STDOUT pipes, and free
        //   the state data structure.
        // ---------------------------------------------
         if (chd.pipe0 <> -1);
            callp close(chd.pipe0);
         endif;

         if chd.pipe1>0 and chd.pipe1<= %elem(pipeList);
            pipeList(chd.pipe1) = *null;
         endif;

         callp close(chd.pipe1);

         pid = chd.pid;
         dealloc pip;
         pip = *null;

        // ---------------------------------------------
        //  wait for child process to end, and retrieve
        //  it's status
        // ---------------------------------------------

         rc = waitpid(pid: sts.code: 0);
         if (rc = -1);
            ReportError(-1: ' ');
            return -1;
         endif;

        // ---------------------------------------------
        //   interpret ending status code
        // ---------------------------------------------

         if (sts.type=PIPE_NORMAL);
            sts.fail = %bitand(sts.fail: x'00FF');
         endif;

         if %parms>=2 and %addr(exitType)<>*null;
            exitType = sts.type;
         endif;

         if %parms>=3 and %addr(exitCode)<>*null;
            if (sts.type = PIPE_NORMAL);
               exitCode = sts.fail;
            else;
               exitCode = sts.fail;
            endif;
         endif;

        // ---------------------------------------------
        //   based on ending status, set appropriate
        //   return value for procedure.
        // ---------------------------------------------

         select;
         when (sts.type=PIPE_NORMAL and sts.fail=0);
            return 0;
         when sts.type=PIPE_NORMAL;
            ReportError( sts.type
                       : 'Child process ended with status ' +
                          %char(sts.fail));
            return -1;
         when sts.type=PIPE_SIGNAL;
            ReportError( sts.type
                       : 'Child process ended by signal ' +
                          %char(sts.fail));
            return -1;
         when sts.type=PIPE_STOPPED;
            ReportError( sts.type
                       : 'Child process stopped by signal ' +
                          %char(sts.fail));
            return -1;
         when sts.type=PIPE_EXCP;
            ReportError( sts.type
                       : 'Child process ended with exception ' +
                          %char(sts.fail));
            return -1;
         other;
            ReportError( sts.type
                       : 'Child process endtype=' + %char(sts.type)
                       + ', endcode=' + %char(sts.fail));
            return -1;
         endsl;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * pipe_read(): Read data from the pipe that's connected
      *              to STDOUT/STDERR on the Unix process
      *
      *   pip = (input) connection to read from
      *  line = (output) one line of text read from the process
      *
      *  Returns the length of the line read, or -1 upon failure
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P pipe_read       B                   export
     D pipe_read       pi            10i 0 opdesc
     D   pip                           *   value
     D   line                     65535a   varying options(*varsize)

     D type            s             10i 0
     D curlen          s             10i 0
     D maxlen          s             10i 0
     D newlen          s             10i 0
     D dataOffset      s             10i 0

      /free
        CEEGSI(2: type: curlen: maxlen);
        %len(line) = maxlen;

        // in 6.1, varying fields can have either a
        // 4-byte length prefix or a 2-byte length
        // prefix.  (In earlier releases, it's always 2.)

        if type = 5;
           dataOffset = 4;
        else;
           dataOffset = 2;
        endif;

        newlen = pipe_readb( pip
                           : %addr(line) + dataOffset
                           : maxlen );
        if (newlen = -1);
          %len(line) = 0;
        else;
          %len(line) = newlen;
        endif;

        return newlen;
      /end-free
     P                 E


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
     P pipe_readf      B                   export
     D pipe_readf      pi            10i 0 opdesc
     D   pip                           *   value
     D   line                     65535a   options(*varsize)

     D type            s             10i 0
     D curlen          s             10i 0
     D maxlen          s             10i 0
     D newlen          s             10i 0

      /free
        CEEGSI(2: type: curlen: maxlen);

        newlen = pipe_readb( pip
                           : %addr(line)
                           : maxlen );
        if (newlen = -1);
          %subst(line:1:maxlen) = *blanks;
        endif;

        return newlen;
      /end-free
     P                 E


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
     P pipe_readb      B                   export
     D pipe_readb      pi            10i 0
     D   pip                           *   value
     D   buf                           *   value
     D   size                        10u 0 value

     D EolChk          s              2a   based(p_EolChk)
     D char            s              1a
     D chd             ds                  likeds(child_t)
     D                                     based(pip)
     D curlen          s             10i 0
     D len             s             10i 0
     D pos             s             10i 0
     D left            s             10i 0

      /free
        if (pip = *null);
           ReportError( 90001
                      : 'Attempt to read from a null pipe.');
           return -1;
        endif;

        if (chd.pipe0 <> -1);
           pipe_done(pip);
        endif;

        // ---------------------------------------------
        //   Get string size from OPDESC.
        // ---------------------------------------------
        memset(buf: x'40': size);
        curlen = 0;
        left = size;

        // ---------------------------------------------
        //  This loop:
        //     - proceeds until no space is left, or
        //          an EOL character is found.
        //     - if necessary, adds more data to buffer
        //     - uses as much of buffer as possible,
        //          up to EOL char (if found)
        // ---------------------------------------------
        dou left<1 or pos>0;

           // refill buffer if needed

           if chd.p1str > %len(chd.p1buf);
              chd.p1str = 1;
              %len(chd.p1buf) = %size(chd.p1buf) - VARPREF;
              len = read(chd.pipe1: %addr(chd.p1buf)+2: %len(chd.p1buf));
              if (len < 1);
                %len(chd.p1buf) = 0;
                leave;
              endif;
              %len(chd.p1buf) = len;
           endif;

           // look for EOL.  Use that to determine
           //   length of data to extract.

           pos = %scan(chd.EOL: chd.p1buf: chd.p1str);
           if (pos > 0);
              len = (pos - chd.p1str) + %len(chd.EOL);
              if (len > left);
                 len = left;
              endif;
           else;
              len = (%len(chd.p1buf) - chd.p1str) + 1;
              if (len > left);
                 len = left;
              endif;
           endif;

           //  extract data from buffer

           memcpy( buf+curlen
                 : %addr(chd.p1buf) + chd.p1str + 1
                 : len );
           curlen += len;
           chd.p1str += len;
           left -= len;

        enddo;

        // ---------------------------------------------
        //  if we didn't manage to get anything from
        //  either the buffer or the pipe, then the
        //  pipe must've broken (process ended?)
        // ---------------------------------------------

        if curlen = 0;
           return -1;
        endif;

        // ---------------------------------------------
        //   Strip EOL from data received, and exit
        // ---------------------------------------------

        len = %len(chd.EOL);
        pos = curlen - len;

        if curlen>len;
          p_EolChk = buf + pos;
          if (%subst(EolChk:1:len) = chd.EOL);
             %subst(EolChk:1:len) = *blanks;
             curlen -= len;
          endif;
        endif;

        return curlen;
      /end-free
     P                 E


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
     P pipe_write      B                   export
     D pipe_write      pi            10i 0
     D   pip                           *   value
     D   line                     65535a   varying const options(*varsize)

     D writebCheat     pr            10i 0 extproc('PIPE_WRITEB')
     D   pip                           *   value
     D   buf                      65535a   const options(*varsize)
     D   len                         10u 0 value

      /free
         return writebCheat( pip: line: %len(line) );
      /end-free
     P                 E


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
     P pipe_writef     B                   export
     D pipe_writef     pi            10i 0 opdesc
     D   pip                           *   value
     D   line                     65535a   const options(*varsize)

     D type            s             10i 0
     D curlen          s             10i 0
     D maxlen          s             10i 0

      /free
        CEEGSI(2: type: curlen: maxlen);
        return writebCheat( pip: line: curlen );
      /end-free
     P                 E


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
     P pipe_writeb     B                   export
     D pipe_writeb     pi            10i 0
     D   pip                           *   value
     D   buf                           *   value
     D   len                         10u 0 value

     D chd             ds                  likeds(child_t)
     D                                     based(pip)

     D writeA          PR            10i 0 extproc('write')
     D   fd                          10i 0 value
     D   data                     65535a   const options(*varsize)
     D   len                         10i 0 value

     D write           PR            10i 0 extproc('write')
     D   fd                          10i 0 value
     D   data                          *   value
     D   len                         10u 0 value
      /free
         // -------------------------------------
         //   validate parameters
         // -------------------------------------
          if (pip = *null);
             ReportError( 90001
                        : 'Attempt to write to a null pipe.');
             return -1;
          endif;
          if (chd.pipe0 = -1);
             ReportError( 90002
                        : 'Pipe has already been marked "done"');
             return -1;
          endif;

         // -------------------------------------
         //   write data to pipe
         // -------------------------------------
          if write(chd.pipe0: buf: len) < len;
            ReportError(-1: ' ');
            return -1;
          endif;

         // -------------------------------------
         //   write EOL to pipe
         // -------------------------------------
          if writeA(chd.pipe0: chd.EOL: %len(chd.EOL)) < %len(chd.EOL);
            ReportError(-1: ' ');
            return -1;
          endif;

          return len + %len(chd.EOL);
      /end-free
     P                 E


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
     P pipe_done       B                   export
     D pipe_done       pi
     D   pip                           *   value
     D chd             ds                  likeds(child_t)
     D                                     based(pip)
      /free
        if (pip <> *null);
           callp close(chd.pipe0);
           chd.pipe0 = -1;
        endif;
      /end-free
     P                 E


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
     P pipe_setEol     B                   export
     D pipe_setEol     pi
     D   pip                           *   value
     D   newEol                       2a   varying const

     D chd             ds                  likeds(child_t)
     D                                     based(pip)
      /free
         chd.eol = newEol;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * pipe_error():  Return info about the last error that
      *                occurred in this module
      *
      *   errnum = (output/optional) error number identifying the
      *                error that last occurred.
      *
      *  returns a message identifying the last error
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P pipe_error      B                   export
     D pipe_error      pi            80a   varying
     D   errnum                      10i 0 options(*omit:*nopass)
      /free
         if %parms>=1 and %addr(errnum)<>*null;
            errnum = last.msgno;
         endif;
         return last.msg;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * INTERNAL:  Set the last error that occurred in this module
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P ReportError     B
     D ReportError     PI
     D   msgno                       10i 0 value
     D   msg                         80a   varying const
     D QMHSNDPM        PR                  ExtPgm('QMHSNDPM')
     D   MessageID                    7A   Const
     D   QualMsgF                    20A   Const
     D   MsgData                    256A   Const
     D   MsgDtaLen                   10I 0 Const
     D   MsgType                     10A   Const
     D   CallStkEnt                  10A   Const
     D   CallStkCnt                  10I 0 Const
     D   MessageKey                   4A
     D   ErrorCode                   20i 0 const
     D key             s              4a
     D get_errno       PR              *   ExtProc('__errno')
     D strerror        PR              *   ExtProc('strerror')
     D    errnum                     10I 0 value
     D err             s             10i 0 based(p_err)
      /free
         if (msgno=-1);
            p_err = get_errno();
            last.msgno = err;
            last.msg   = %str(strerror(err));
         else;
            last.msgno = msgno;
            last.msg   = msg;
         endif;

         // Log this message as a diagnostic message in
         // the job log.  Assists with troubleshooting.

         if (%len(last.msg)>0 and last.msg<>*blanks);
            QMHSNDPM('CPF9897': 'QCPFMSG   *LIBL': last.msg
                    : %len(last.msg): '*DIAG': '*': 0: key: 0);
         endif;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * pipe_getId(): Get the pipe id number for a pipe
      *
      *   pip = (input) the pipe's child handle
      *                 (as returned by pipe_open)
      *
      * returns the pipeid number, or -1 upon error
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P pipe_getId      B                   export
     D pipe_getId      pi            10i 0
     D   pip                           *   value
     D chd             ds                  likeds(child_t)
     D                                     based(pip)
      /free
        if (pip <> *null);
          return chd.pipe1;
        else;
          return -1;
        endif;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * pipe_getHandle(): Get the child handle for a given pipeid
      *
      *   pipeid = (input) the pipeid to find the handle for
      *
      * returns the handle, or *null if it's not found
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P pipe_getHandle  B                   export
     D pipe_getHandle  pi              *
     D   pipeid                      10i 0 value
      /free
         if pipeId = -2;
            return lastPipe;
         elseif pipeId<1 or pipeId>%elem(pipeList);
            return *null;
         else;
            return pipeList(pipeId);
         endif;
      /end-free
     P                 E
