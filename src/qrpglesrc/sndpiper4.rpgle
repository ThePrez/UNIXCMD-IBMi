      *  SNDPIPER4 -- Write data to a Unix process over a pipe.
      *               (This is the CPP for the SNDPIPE command.)
      *                                     Scott Klement, January 14, 2010
      *
      * To compile:
      *    ** The BUILDIT CL program included with this code
      *       will compile this along with everything else.
      *    ** to recompile this program standalone, type the following:
      *>      CRTRPGMOD MODULE(SNDPIPER4) SRCFILE(QRPGLESRC) DBGVIEW(*LIST)
      *>      CRTPGM SNDPIPER4 ACTGRP(UNIXCMD) BNDSRVPGM(UNIXPIPER4)
      *>      CRTPNLGRP SNDPIPE SRCFILE(QPNLSRC)
      *>      CRTCMD CMD(SNDPIPE) PGM(SNDPIPER4) -
      *>             ALLOW(*IPGM *IMOD *BPGM *BMOD) -
      *>             HLPPNLGRP(SNDPIPE) HLPID(SNDPIPE)
      *> ign: DLTMOD SNDPIPER4
     /*-                                                                            +
      * Copyright (c) 2010-2016 Scott C. Klement                                    +
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

     D SNDPIPE         PR                  ExtPgm('SNDPIPER4')
     D   Rcd                      65535a   varying const
     D   PipeId                      10p 0 const
     D SNDPIPE         PI
     D   Rcd                      65535a   varying const
     D   PipeId                      10p 0 const

      /copy unixpipe_h

     D QMHSNDPM        PR                  ExtPgm('QMHSNDPM')
     D   MessageID                    7A   Const
     D   QualMsgF                    20A   Const
     D   MsgData                  32767A   Const options(*varsize)
     D   MsgDtaLen                   10I 0 Const
     D   MsgType                     10A   Const
     D   CallStkEnt                  10A   Const
     D   CallStkCnt                  10I 0 Const
     D   MessageKey                   4A
     D   ErrorCode                32767A   options(*varsize)

     D Kaboom          ds                  qualified
     D   bytesProv                   10i 0 inz(0)
     D   bytesAvail                  10i 0 inz(0)

     D h               s               *
     D MsgKey          S              4A
     D errMsg          s             80a   varying

      /free
          h = pipe_getHandle(PipeId);
          if (h = *null);
             errMsg = 'Pipe doesn''t exist.';
             QMHSNDPM( 'CPF9897'
                     : 'QCPFMSG   *LIBL'
                     : errMsg
                     : %len(errMsg)
                     : '*ESCAPE'
                     : '*PGMBDY'
                     : 1
                     : MsgKey
                     : Kaboom );
             return;
          endif;

          if pipe_write(h: Rcd) = -1;
             QMHSNDPM( 'CPE3455'
                     : 'QCPFMSG   *LIBL'
                     : ' '
                     : 0
                     : '*ESCAPE'
                     : '*PGMBDY'
                     : 1
                     : MsgKey
                     : Kaboom );
             return;
          endif;

          return;
      /end-free
