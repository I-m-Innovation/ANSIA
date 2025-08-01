function Reports=makeReport(Data)


ok=0;

try
[PonteGiurinoReport, PGName]=ReportH2O("PG",Data.PonteGiurino);
catch err
    PonteGiurinoReport=[];
end


if isempty(PonteGiurinoReport)==0
    
    
    Reports.PonteGiurino.Table=PonteGiurinoReport;
    Reports.PonteGiurino.FileName=PGName;

else
    Reports.PonteGiurino.Table="<h2><font color="+char(34)+"red"+char(34)+">PONTE GIURINO<br>REPORT NON RIUSCITO! CONTROLLARE FUNZIONAMENTO IMPIANTO!!!!</font></h2>";
end

try
[PartitoreReport, PartitoreName]=ReportH2O("Partitore",Data.Partitore);
catch err
    Obj = "DEBUG ANSIA";
    errReport(app,err,Obj);
    PartitoreReport=[];
end

if isempty(PartitoreReport)==0

    ok=ok+1;
    Reports.Partitore.Table=PartitoreReport;
    Reports.Partitore.FileName=PartitoreName;
else
    Reports.Partitore.Table="<h2><font color="+char(34)+"red"+char(34)+">PARTITORE<br>REPORT NON RIUSCITO! CONTROLLARE FUNZIONAMENTO IMPIANTO!!!!</font></h2>";
end



try
[SanTeodoroReport, STName]=ReportH2O("ST",Data.SanTeodoro);
catch err
    Obj = "DEBUG ANSIA";
    errReport(app,err,Obj);
    SanTeodoroReport=[];
end

if isempty(SanTeodoroReport)==0

    ok=ok+1;
    Reports.SanTeodoro.Table=SanTeodoroReport;
    Reports.SanTeodoro.FileName=STName;

else
    Reports.SanTeodoro.Table="<h2><font color="+char(34)+"red"+char(34)+">SAN TEODORO<br>REPORT NON RIUSCITO! CONTROLLARE FUNZIONAMENTO IMPIANTO!!!!</font></h2>";
end

try
[RubinoReport, RubinoName]=ReportPV("Rubino",Data.Rubino);
catch err

    Obj = "DEBUG ANSIA";
    errReport(app,err,Obj);
    RubinoReport=[];
    
end

if ismissing(RubinoReport)==0

    ok=ok+1;
    Reports.Rubino.Table=RubinoReport;
    Reports.Rubino.FileName=RubinoName;
else

    Reports.Rubino.Table="<h2><font color="+char(34)+"red"+char(34)+">RUBINO<br>REPORT NON RIUSCITO! CONTROLLARE FUNZIONAMENTO IMPIANTO!!!!</font></h2>";

end

try
[SCNReport, SCNName]=ReportPV("SCN",Data.SCN);
catch err
    Obj = "DEBUG ANSIA";
    errReport(app,err,Obj);
    SCNReport=[];
end

if ismissing(SCNReport)==0
    ok=ok+1;
    Reports.SCN.Table=SCNReport;
    Reports.SCN.FileName=SCNName;

else
    Reports.SCN.Table="<h2><font color="+char(34)+"red"+char(34)+">SCN - PILOTA<br>REPORT NON RIUSCITO! CONTROLLARE FUNZIONAMENTO IMPIANTO!!!!</font></h2>";
end


end