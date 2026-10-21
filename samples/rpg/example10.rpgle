**FREE
// This is the same as EXAMPLE3, except that it is in "fully free"
// format and uses Open Access instead of Special Files
//
dcl-f UNIX disk(5) usage(*input:*output) handler('UNIXCMDOA':cmd);
dcl-s cmd char(5000) inz('iconv -f 819 -t 0');
dcl-ds record len(5) end-ds;
dcl-c AsciiData x'48656c6c6f';

record = AsciiData;
write UNIX record;
read UNIX record;
dsply record;

*inlr = *on;
