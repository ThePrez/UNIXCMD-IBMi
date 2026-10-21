     FUNIX      O    F 1000        SPECIAL PGMNAME('UNIXCMD')
     F                                     PLIST(UNIXPARM) USROPN

     D cmd             s           5000a

     C     UNIXPARM      PLIST
     C                   PARM                    CMD
      /free
          cmd = 'cat - > /tmp/myfile.txt';
          open UNIX;

          except writeToIfs;
          close UNIX;

          *inlr = *on;
      /end-free

     OUNIX      E            writeToIfs
     O                                              'This is some silly -
     O                                              text to put in the IFS'
     O          E            writeToIfs
     O                                              'And this is line 2.'
