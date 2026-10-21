        dcl-f UNIX special(1000) pgmname('UNIXCMD') plist(unixparm) usropn;
        dcl-f QSYSPRT printer(132) usage(*output);
        dcl-s cmd char(5000);
        dcl-ds record len(1000) end-ds;
        dcl-ds outrec len(132) end-ds;

     C     UNIXPARM      PLIST
     C                   PARM                    cmd

        cmd = 'cd /tmp; ls';
        open UNIX;

        read UNIX record;
        dow not %eof(UNIX);
           outrec = record;
           write QSYSPRT outrec;
           read UNIX record;
        enddo;

        close UNIX;
        *inlr = *on;

