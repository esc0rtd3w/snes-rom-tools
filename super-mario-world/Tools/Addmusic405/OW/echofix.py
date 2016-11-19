import os
import re
#tag = re.compile("\$EF \$.. \$.. \$..")
fix = "$ED $80 $6D $68\n$ED $80 $7D $00\n$F0\n"
#fix = ""
ls = os.listdir(".")
for i in ls:
    #print i[len(i)-3:len(i)]
    if i[len(i)-3:len(i)] == "txt":
        try:
            tmpfile = open(i,"r")
            text = tmpfile.read()
            tmpfile.close()
            #found = tag.search(text)
            #if found:
            writefile = open(i,"w")
            text = fix + text
            writefile.write(text)
            writefile.close()
            
        except:
            pass
