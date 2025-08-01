function readAndSendPV(app)

try
    PonteGiurinoData=ReadPonteGiurinoData(app);
% catch err
%     Recipients="stefano.trevisan@zilioservice.com";
%     TEXT="Origine Errore: ReadPonteGiurinoData()"+newline+"Codice Errore: "+string(err.message)
%     sendmail2(Recipients,"Debug de L'ansia",TEXT{:});
end

try
PartitoreData=ReadPartitoreData(app);
% catch err   
%     Recipients="stefano.trevisan@zilioservice.com";
%     TEXT="Origine Errore: ReadPartitoreData()"+newline+"Codice Errore: "+string(err.message)
%     sendmail2(Recipients,"Debug de L'ansia",TEXT{:});    
end

try
SanTeodoroData=ReadSanTeodoroData(app);
% catch err
%     Recipients="stefano.trevisan@zilioservice.com";
%     TEXT="Origine Errore: ReadSanTeodoroData()"+newline+"Codice Errore: "+string(err.message)
%     sendmail2(Recipients,"Debug de L'ansia",TEXT{:});        
end

try
    RubinoData=ReadRubinoData();
% catch err
%     Recipients="stefano.trevisan@zilioservice.com";
%     TEXT="Origine Errore: ReadRubinoData()"+newline+"Codice Errore: "+string(err.message)
%     RubinoData=ReadRubinoData();
%     writestruct(RubinoData,"RubinoExport.xml");   
%     sendmail2(Recipients,"Debug de L'ansia",TEXT{:},"RubinoExport.xml");
end

try
    SCNData=ReadSCNData();
% catch err
% 
% 
%     Recipients="stefano.trevisan@zilioservice.com";
%     TEXT="Origine Errore: ReadSCNData()"+newline+"Codice Errore: "+string(err.message);
% %     sendmail2(Recipients,"Debug de L'ansia",TEXT{:});
%     writestruct(SCNData,"SCNExport.xml");   
%     sendmail2(Recipients,"Debug de L'ansia",TEXT{:},"SCNExport.xml");

end

ok=0;

try
[PonteGiurinoReport, PGName]=ReportH2O("PG",PonteGiurinoData);
ok=ok+1;
Reports(ok)=PonteGiurinoReport;
% catch err
%     PonteGiurinoReport="ERRORE";
%     PGName="";
%     Recipients="stefano.trevisan@zilioservice.com";
%     TEXT="Origine Errore: ReportH2O()"+newline+"Impianto: Ponte Giurino"+newline+"Codice Errore: "+string(err.message);
%     sendmail2(Recipients,"Debug de L'ansia",TEXT{:});    
end

try
[PartitoreReport, PartitoreName]=ReportH2O("Partitore",PartitoreData);
if ismissing(PartitoreReport)==0
ok=ok+1;
Reports(ok)=PartitoreReport;
end

% catch err
%     PartitoreReport="";
%     PartitoreName="";
%     Recipients="stefano.trevisan@zilioservice.com";
%     TEXT="Origine Errore: ReportH2O()"+newline+"Impianto: Partitore"+newline+"Codice Errore: "+string(err.message);
%     sendmail2(Recipients,"Debug de L'ansia",TEXT{:});
end

try
[SanTeodoroReport, STName]=ReportH2O("ST",SanTeodoroData);
ok=ok+1;
Reports(ok)=SanTeodoroReport;
% catch err
%     Recipients="stefano.trevisan@zilioservice.com";
%     TEXT="Origine Errore: ReportH2O()"+newline+"Impianto: San Teodoro"+newline+"Codice Errore: "+string(err.message);
%     sendmail2(Recipients,"Debug de L'ansia",TEXT{:});    
end

try
[RubinoReport, RubinoName]=ReportPV("Rubino",RubinoData);
if ismissing(RubinoReport)==0
ok=ok+1;
Reports(ok)=RubinoReport;
end
% catch err
%     Recipients="stefano.trevisan@zilioservice.com";
%     TEXT="Origine Errore: ReportPV()"+newline+"Impianto: Rubino"+newline+"Codice Errore: "+string(err.message);
%     sendmail2(Recipients,"Debug de L'ansia",TEXT{:});       
end

try
[SCNReport, SCNName]=ReportPV("SCN",SCNData);
if ismissing(SCNReport)==0
ok=ok+1;
Reports(ok)=SCNReport;
end
% catch
%     Recipients="stefano.trevisan@zilioservice.com";
%     TEXT="Origine Errore: ReportPV()"+newline+"Impianto: SCN"+newline+"Codice Errore: "+string(err.message);
%     sendmail2(Recipients,"Debug de L'ansia",TEXT{:});
end

try
    OverallReport=unifyReport(Reports);
% catch err
%     OverallReport=unifyReport(PonteGiurinoReport,"","",PartitoreReport,SanTeodoroReport);
%     Recipients="stefano.trevisan@zilioservice.com";
%     TEXT="Origine Errore: unifyReport()"+newline+"Codice Errore: "+string(err.message);
%     sendmail2(Recipients,"Debug de L'ansia",TEXT{:});
end


[Recipients,mailObj]=setEmailOptions(app);
FileName=[SCNName,RubinoName,PGName,PartitoreName,STName];
FileName=FileName(FileName~="");

try
sendmail2(Recipients,mailObj,OverallReport{:},FileName);
% catch
% OverallReport=unifyReport(PonteGiurinoReport,"","",PartitoreReport,SanTeodoroReport);
% FileName=[PGName,PartitoreName,STName];
% sendmail2(Recipients,mailObj,OverallReport{:},FileName);
end

app.LogTextArea.Value=[app.LogTextArea.Value;"Report delle"+string(datetime('now','Format','HH:mm:ss'))+" inviato correttamente."]

delete(FileName{:});
end