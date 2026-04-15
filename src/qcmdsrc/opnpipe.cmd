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
                                                                               +
      CMD PROMPT('Open Pipe & Run Unix Cmd')

      PARM KWD(CMD) TYPE(*CHAR) LEN(5000) VARY(*YES) +
           MIN(1) EXPR(*YES) CASE(*MIXED) +
           PROMPT('Command to run')

      PARM KWD(TYPE) TYPE(*CHAR) LEN(1) RSTD(*YES) +
           EXPR(*YES) DFT(*QSHELL) SPCVAL((*QSHELL Q) (*PASE P)) +
           PROMPT('Command environment')

      PARM KWD(PIPEID) TYPE(*DEC) LEN(10 0) +
           RTNVAL(*YES) +
           PMTCTL(*PMTRQS) +
           PROMPT('CL VAR for Pipe ID')
