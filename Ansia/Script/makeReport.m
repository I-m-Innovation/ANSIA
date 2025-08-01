function Reports=makeReport(Data)

ok=0;

try
    [SA3Report, SA3Name]=ReportH2O("SA3",Data.SA3);
catch
    SA3Report=[];
end

if isempty(SA3Report)==0

    ok=ok+1;
    Reports.SA3.Table=SA3Report;
    Reports.SA3.FileName=SA3Name;

else
    Reports.SA3.Table='<h2>SA3<br></h2><br><body><center><font color="red";size =20><b>NO LINK</b></font></center></body><br>';
end

try
    [TorrinoForestaReport, TFName]=ReportH2O("TF",Data.TorrinoForesta);
catch
    TorrinoForestaReport=[];
end

if isempty(TorrinoForestaReport)==0

    Reports.TorrinoForesta.Table=TorrinoForestaReport;
    Reports.TorrinoForesta.FileName=TFName;

else
    Reports.TorrinoForesta.Table='<h2>Torrino Foresta<br></h2><br><body><center><font color="red";size =20><b>NO LINK</b></font></center></body>';
end



try
    [PonteGiurinoReport, PGName]=ReportH2O("PG",Data.PonteGiurino);
catch err
    err.message
    PonteGiurinoReport=[];
end


if isempty(PonteGiurinoReport)==0

    Reports.PonteGiurino.Table=PonteGiurinoReport;
    Reports.PonteGiurino.FileName=PGName;

else
    Reports.PonteGiurino.Table='<h2>Ponte Giurino<br></h2><br><body><center><font color="red";size =20><b>NO LINK</b></font></center></body><br>';
end

try
    [PartitoreReport, PartitoreName]=ReportH2O("Partitore",Data.Partitore);
catch
    PartitoreReport=[];
end

if isempty(PartitoreReport)==0

    ok=ok+1;
    Reports.Partitore.Table=PartitoreReport;
    Reports.Partitore.FileName=PartitoreName;

else
    Reports.Partitore.Table='<h2>Partitore<br></h2><br><body><center><font color="red";size =20><b>NO LINK</b></font></center></body><br>';
end



try
    [SanTeodoroReport, STName]=ReportH2O("ST",Data.SanTeodoro);
catch
    SanTeodoroReport=[];
end
if isempty(SanTeodoroReport)==0

    ok=ok+1;
    Reports.SanTeodoro.Table=SanTeodoroReport;
    Reports.SanTeodoro.FileName=STName;

else
    Reports.SanTeodoro.Table='<h2>San Teodoro<br></h2><br><body><center><font color="red";size =20><b>NO LINK</b></font></center></body><br>';
end

% try
%     [RubinoReport, RubinoName]=ReportPV("Rubino",Data.Rubino);
% catch
%     RubinoReport=[];
% end
% 
% if isempty(RubinoReport)==0
% 
%     ok=ok+1;
%     Reports.Rubino.Table=RubinoReport;
%     Reports.Rubino.FileName=RubinoName;
% else
% 
%     Reports.Rubino.Table='<h2>Rubino<br></h2><br><body><center><font color="red";size =20><b>NO LINK</b></font></center></body><br>';
% 
% end
% 
% try
%     [SCNReport, SCNName]=ReportPV("SCN",Data.SCN);
% catch
%     SCNReport=[];
% end
% 
% if isempty(SCNReport)==0
%     ok=ok+1;
%     Reports.SCN.Table=SCNReport;
%     Reports.SCN.FileName=SCNName;
% 
% else
%     Reports.SCN.Table='<h2>SCN Pilota<br></h2><br><body><center><font color="red";size =20><b>NO LINK</b></font></center></body><br>';
% end


end