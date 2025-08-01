function [TEXT, nameFile]=ReportH2O(PlantName,Data)

if PlantName=="PG"

    Title="Ponte Giurino";
    conc=80;

elseif PlantName=="Partitore"

    Title="Partitore";
    conc=25;
else
    
    Title="San Teodoro";
    conc=70;
end


LastTime=Data.timeStamp(end);
LastFlowValue=Data.Flow(end);
LastPowValue=Data.Power(end);
LastHValue=Data.Pressure(end)*10.1974;


LastEtaValue=round(1000*LastPowValue/(9.81*LastHValue*LastFlowValue)*100);
if isnan(LastEtaValue)
    LastEtaValue="N.D.";
else
    LastEtaValue=string(LastEtaValue);
end

Vol=Data.VolumeDerivato;
Eprod=round(Data.Eprod);
HMean=mean(Data.Pressure)*10.1974;
percConc=round(Vol/(conc/1000*3600*24)*100/1000);

DailyEta=round(100*1000*Eprod*3600/(9.81*Vol*HMean));
if isnan(DailyEta)
    DailyEta="N.D.";
else
    DailyEta=string(DailyEta);
end

TextTable1=createTable("H2O","Now",string(datetime(LastTime,'Format','HH:mm')),string(round(LastFlowValue)),string(round(LastPowValue)),LastEtaValue,0);
TextTable2=createTable("H2O","Today",string(datetime(LastTime,'Format','dd/MM/uuuu')),round(Vol/1000),string(round(Eprod)),DailyEta,percConc);
BODY=TextTable1+"<br>"+TextTable2;


[nameFile,L,H]=createPlot(Data,PlantName,"H2O");

IMMAGE="<center><img width="+char(34)+L+char(34)+" height="+char(34)+H+char(34)+" id="+char(34)+"1"+char(34)+"src="+char(34)+"cid:"+nameFile+char(34)+"></center>";

TEXT="<h2>"+Title+"<br></h2><br>"+BODY+"<br>"+IMMAGE;

end