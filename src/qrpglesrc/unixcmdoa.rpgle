      * This is program that's called by the RPG open access (HANDLER)
      * file interface that that enables you to run Unix commands
      * and interact with their input/output streams.
      *
      * It uses the UNIXPIPER4 service program to launch the commands
      * and read/write their data streams.
      *                                Scott Klement, November 21, 2016
      *
      * To compile:
      *>     CRTRPGMOD UNIXCMDOA DBGVIEW(*LIST)
      *>     CRTPGM UNIXCMDOA ACTGRP(KLEMENT) BNDSRVPGM(UNIXPIPER4)
      *

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


     H option(*srcstmt:*nodebugio:*noshowcpy)
     H COPYRIGHT('UNIXCMD 1.3 Copyright (c) 2010-2016 Scott C. Klement')

     D UNIXPIPEOA      PR                  ExtPgm('UNIXPIPEOA')
     D   io                                likeds(QrnOpenAccess_t)
     D                 PI
     D   io                                likeds(QrnOpenAccess_t)

      /copy QRNOPENACC
      /copy UNIXPIPE_H

     D lower           c                   'abcdefghijklmnopqrstuvwxyz'
     D UPPER           c                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

     D outrec          s          65535a   based(p_outrec)
     D cmdbuf          s           5000a   based(p_cmdbuf)
     D
     D cmd             s           5000a   varying
     D type            s              1a   inz('Q')

     D err             s             10i 0
     D code            s              5u 0
     D pos             s             10i 0
     D len             s             10i 0
     D h               s               *   inz(*null)
     D typechk         s             10a   varying

      /free

       io.rpgStatus = 0;

       select;
       when io.rpgOperation = QrnOperation_OPEN;

          // status 1215 = OPEN issued to a file already opened.
          if h <> *null;
             io.rpgStatus = 1215;
             return;
          endif;

          // 1217 = Error on an explicit OPEN/CLOSE operation.
          p_cmdbuf = io.userArea;
          if p_cmdbuf = *null;
             io.rpgStatus = 1217;
             return;
          endif;

          cmd = %trimr(cmdbuf);

          typechk = *blanks;
          pos = %scan(':': cmd);
          if pos>2 and pos<10;
             typechk = %subst(cmd:1:pos-1);
             typechk = %xlate(lower: UPPER: typechk);
          endif;

          type = 'Q';
          select;
          when typechk = 'QSH' or typechk='QSHELL';
             type = 'Q';
             cmd = %subst(cmd:%len(typechk)+2);
          when typechk = 'RAW';
             type = ' ';
             cmd = %subst(cmd:%len(typechk)+2);
          when typechk = 'PASE';
             type = 'P';
             cmd = %subst(cmd:%len(typechk)+2);
          endsl;

          io.useNamesValues = *off;
          io.found = *off;
          io.equal = *off;
          io.eof = *off;

          io.openFeedbackLen = 0;
          io.ioFeedbackLen = 0;
          io.deviceFeedbackLen = 0;
          io.rrn = 0;

          h = pipe_open(cmd: type);
          if (h = *null);
             pipe_error(err);
             // 1217 = Error on an explicit OPEN/CLOSE operation.
             io.rpgStatus = 1217;
          endif;

       when io.rpgOperation = QrnOperation_CLOSE;

          if (h <> *null);
             if pipe_close(h: *omit: code) = -1;
                // 1217 = Error on an explicit OPEN/CLOSE operation.
                io.rpgStatus = 1217;
             endif;
             h = *null;
          endif;

       when h = *null;

          // status 1211 = I/O operation to a closed file.
          io.rpgStatus = 1211;
          return;

       when io.rpgOperation = QrnOperation_READ;

          len = pipe_readb(h: io.inputBuffer: io.inputBufferLen);
          if len = -1;
             io.eof   = *on;
             io.found = *off;
             io.equal = *off;
             io.inputDataLen = 0;
          else;
             io.eof   = *off;
             io.found = *on;
             io.equal = *on;
             io.inputDataLen = len;
          endif;

       when io.rpgOperation = QrnOperation_WRITE
         or io.rpgOperation = QrnOperation_UPDATE;

          p_outrec = io.outputBuffer;
          len = %len(%trimr(%subst(outrec:1:io.outputBufferLen)));
          if pipe_writeb(h: io.outputBuffer: len) = -1;
             pipe_error(err);
             // 1299 = Other I/O error detected
             io.rpgStatus = 1299;
          endif;

       when io.rpgOperation = QrnOperation_FEOD;

          pipe_done(h);
          io.eof = *on;

       other;
          // 1299 = Other I/O error detected
          io.rpgStatus = 1299;
          // FIXME: maybe send an exception message?

       endsl;

       return;
