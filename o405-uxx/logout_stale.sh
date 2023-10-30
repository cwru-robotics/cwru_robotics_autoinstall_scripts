#/!/bin/sh
kill `who -u | gawk '/old/ {print $6}' - ` 
