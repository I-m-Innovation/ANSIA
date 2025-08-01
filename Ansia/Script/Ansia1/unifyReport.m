function OverallReport=unifyReport(Report)

TITLE="<h1><center>Report giornaliero impianti</center></h1><br>";
Names=fieldnames(Report);

for i=1:length(fieldnames(Report(:)))

    Nom=string(Names(i));

    if i==1
        BODY=Report.(Nom).Table+"<br><hr align="+char(34)+"center"+char(34)+" size="+char(34)+"2"+char(34)+" width="+char(34)+"400"+char(34)+" color="+char(34)+"black"+char(34)+" noshade><br>";
    else
        BODY=BODY+Report.(Nom).Table+"<br><hr align="+char(34)+"center"+char(34)+" size="+char(34)+"2"+char(34)+" width="+char(34)+"400"+char(34)+" color="+char(34)+"black"+char(34)+" noshade><br>";
    end
end

OverallReport=TITLE+BODY;
end