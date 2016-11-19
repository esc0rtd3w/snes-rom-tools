import os
import re
fix = "$ED $80 $6D $2B\n$ED $80 $7D $00\n$F0\n"
ls = os.listdir(".")
for i in ls:
    if i[len(i)-3:len(i)] == "txt":
        try:
            tmpfile = open(i,"r")
            text = tmpfile.read()
            tmpfile.close()
            writefile = open(i,"w")
            text = fix + text
            writefile.write(text)
            writefile.close()
            
        except:
            print 'Failed to write to file: %s \nAre you sure permissions are set correctly for it?' % i
            pass
raw_input("Done!")
