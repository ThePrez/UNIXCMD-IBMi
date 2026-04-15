     FUNIX      UF   F 1000        SPECIAL PGMNAME('UNIXCMD')
     F                                     PLIST(UNIXPARM) USROPN

     D cmd             s           5000a
     D record          s           1000a
     D AsciiData       c                   x'48656c6c6f'

     IUNIX      NS
     I                                  1 1000  record

     C     UNIXPARM      PLIST
     C                   PARM                    CMD
      /free
          cmd = 'iconv -f 819 -t 0';
          open UNIX;

          except writeAscii;
          read UNIX;
          dsply (%subst(record:1:5));

          close UNIX;

          *inlr = *on;
      /end-free

     OUNIX      E            writeAscii
     O                       AsciiData            5
