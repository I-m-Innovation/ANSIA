function readAndSend(app)

try
    Data=uploadPlantsData(app);
catch err
    err.message;
end

try
    Reports=makeReport(Data);
catch err
    err.message;
end


try
    OverallReport=unifyReport(Reports);
catch err
    err.message
end


[Recipients,mailObj]=setEmailOptions(app);

Names=fieldnames(Reports);


nAtt = 1;
NMax = length(fieldnames(Reports(:)));
FileName = strings(NMax);

for i=1:length(fieldnames(Reports(:)))

    Nome=string(Names(i));

    try
        FileName(nAtt)=Reports.(Nome).FileName;
        nAtt=nAtt+1;
    catch err
        err.message
    end

end
FileName = FileName(1:nAtt-1);

try
    sendmail2(Recipients,mailObj,OverallReport{:},FileName);
catch err
    err.message
end

app.LogTextArea.Value=[app.LogTextArea.Value;"Report delle"+string(datetime('now','Format','HH:mm:ss'))+" inviato correttamente."];
delete(FileName{:});

end