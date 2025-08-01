function readAndSend(app)

Data=uploadPlantsData(app);

Reports=makeReport(Data);

OverallReport=unifyReport(Reports);

[Recipients,mailObj]=setEmailOptions(app);

Names=fieldnames(Reports);

nAtt=1;
for i=1:length(fieldnames(Reports(:)))

    Nome=string(Names(i));
    try

        FileName(nAtt)=Reports.(Nome).FileName;
        nAtt=nAtt+1;
    end
end



sendmail2(Recipients,mailObj,OverallReport{:},FileName);

app.LogTextArea.Value=[app.LogTextArea.Value;"Report delle"+string(datetime('now','Format','HH:mm:ss'))+" inviato correttamente."];
delete(FileName{:});

end