function [TEXT, nameFile]=ReportPV(Data,PlantName)

if PlantName=="SCN"

    Title="SCN - Pilota"
    PlantName="SCN";
    Pp=926.64;

else

    Title="Rubino"
    Pp=997.92;
    PlantName="Rubino";

end

LastIrrTime=Data.irrTime(end);
LastPowTime=Data.powTime(end);

LastIrrValue=round(Data.irrValue(end));
LastPowValue=round(Data.powValue(end));

PR=round(LastPowValue/LastIrrValue/Pp*1000*100);

Eirr=round(Data.Eirr,1);
Eprod=round(Data.Eprod);
PR_day=round(Eprod/Eirr/Pp*100);


if LastIrrTime ==LastPowTime

    TextTable1=createTable("Now",string(datetime(LastIrrTime,'Format','HH:mm')),string(LastIrrValue),string(LastPowValue),string(PR));
    TextTable2=createTable("Today",string(datetime(LastIrrTime,'Format','dd/MM/uuuu')),string(Eirr),string(Eprod),string(PR_day));
    BODY=TextTable1+"<br>"+TextTable2;

else
    BODY="<b>Ultima Potenza</b>:"+string(LastPowValue)+" kW alle "+string(LastPowTime)+"<br>" + ...
        "Ultimo Irraggiamento:"+string(LastIrrValue)+"Wh/m^2 alle"+string(LastIrrTime);
end

[nameFile,L,H]=createPlot(Data,PlantName);

IMMAGE="<center><img width="+char(34)+L+char(34)+" height="+char(34)+H+char(34)+" id="+char(34)+"1"+char(34)+"src="+char(34)+"cid:"+nameFile+char(34)+"></center>";
TEXT="<h2>"+Title+"<br></h2><br>"+BODY+"<br>"+IMMAGE;

end