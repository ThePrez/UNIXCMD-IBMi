**FREE
// This is the same as EXAMPLE5 except that it uses
// "fully free" format and the Open Access interface
//
// To use different "modes" with open access, you prefix
// the command:
//    pase: use the PASE interface
//     qsh: use the QShell interface (also qshell: works too)
//     raw: use raw mode, specify your own shell
// the default mode is "qsh"
//
// This example demonstrates the PASE mode.
//
dcl-f UNIX disk(1000) handler('UNIXCMDOA': cmd) usropn;
dcl-f QSYSPRT printer(132) usage(*output);
dcl-s cmd char(5000);
dcl-ds record len(1000) end-ds;
dcl-ds outrec len(132) end-ds;

cmd = 'pase:cd /tmp; ls';
open UNIX;

read UNIX record;
dow not %eof(UNIX);
   outrec = record;
   write QSYSPRT outrec;
   read UNIX record;
enddo;

*inlr = *on;
