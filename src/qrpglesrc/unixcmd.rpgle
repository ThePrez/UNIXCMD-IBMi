      * This is program that's called by the RPG SPECIAL file interface
      * that enables you to run Unix commands and interact with their
      * input/output streams.
      *
      * It uses the UNIXPIPER4 service program to launch the commands
      * and read/write their data streams.
      *                                Scott Klement, Sept 23, 2009
      *
      * To compile:
      *>     CRTRPGMOD UNIXCMD DBGVIEW(*LIST)
      *>     CRTPGM UNIXCMD ACTGRP(KLEMENT) BNDSRVPGM(UNIXPIPER4)
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

     H OPTION( *SRCSTMT : *NODEBUGIO )
     H COPYRIGHT('UNIXCMD 1.3 Copyright (c) 2010-2016 Scott C. Klement')

     D UNIXCMD         PR                  ExtPgm('UNIXCMD')
     D   option                       1a   const
     D   status                       1a
     D   error                        5s 0
     D   record                   65535a   options(*varsize)
     D   cmd                       5000a   const
     D   type                         1a   const options(*nopass)
     D   recordLen                    5p 0 const options(*nopass)
     D UNIXCMD         PI
     D   option                       1a   const
     D   status                       1a
     D   error                        5s 0
     D   record                   65535a   options(*varsize)
     D   cmd                       5000a   const
     D   type                         1a   const options(*nopass)
     D   recordLen                    5p 0 const options(*nopass)

      /copy unixpipe_h

     D SUCCESS         C                   '0'
     D EOF             C                   '1'
     D FAIL            C                   '2'

     D h               s               *   inz(*null)
     D code            s              5u 0
     D err             s             10i 0
     D len             s             10i 0
     D reclen          s             10i 0 inz(1000)

      /free

         if %parms >= 7;
            reclen = recordLen;
         endif;

         select;
         when option='O';

            if %parms >= 6 and type<>' ';
               h = pipe_open(%trimr(cmd): type);
            else;
               h = pipe_open(%trimr(cmd));
            endif;

            if (h = *null);
              status = FAIL;
              pipe_error(err);
              error = err;
            else;
              status = SUCCESS;
            endif;

         when option='C';
            if (h <> *null);
              if pipe_close(h: *omit: code) = -1;
                 status = FAIL;
                 error  = code;
              else;
                 status = SUCCESS;
              endif;
            endif;

         when h = *null;
            status = FAIL;
            error = 88888;

         when option='R';
            if pipe_readb(h: %addr(record): reclen) = -1;
               status = EOF;
            else;
               status = SUCCESS;
            endif;

         when option='W' or option='U';
            len = %len(%trimr(%subst(record:1:reclen)));
            if pipe_writeb(h: %addr(record): len) = -1;
               status = FAIL;
               pipe_error(err);
               error = err;
            else;
               status = SUCCESS;
            endif;

         when option='F';
            pipe_done(h);
            status = SUCCESS;

         other;
            status = FAIL;
            error = 99999;
         endsl;

         return;
      /end-free
