function     Data=processTF(app,Plant)

    app.CurrPlant=Plant;
    Recipients="monitoraggio@zilioenvironment.com";

try
    delete(app.errLabel)
end

try
    if app.Resize==0
        try
            Data=uploadTFData(app);
        catch err
            TEXT="Errore in 'uploadPGData()'"+newline+string(err.message);
%             sendmail2(Recipients,"DEBUG de L'OCCHIO",TEXT{:});
        end
        
        createCheckBox(app);

        try
            plotIdro(app,Data,Plant);
        catch err
            isNew=identifyError(err,"plotIdro");
            if isNew==1
                TEXT="Errore in 'plotIdro()'"+newline+string(err.message);
%                 sendmail2(Recipients,"DEBUG de L'OCCHIO",TEXT{:});
                isNew=0;
            end
        end
    else

        createCheckBox(app);

        try
            plotIdro(app,app.CurrData,app.CurrPlant);
        catch err
            isNew=identifyError(err,"plotIdro");

            if isNew==1
                TEXT="Errore in 'plotIdro()'"+newline+string(err.message);
%                 sendmail2(Recipients,"DEBUG de L'OCCHIO",TEXT{:});
                isNew=0;
            end
        end

        Data=app.CurrData;

        app.Resize=0;

    end

catch err

    printError(app,err);
    Obj="DEBUG OCCHIO - "+string(Plant);
%     sendmail2('monitoraggio@zilioenvironment.com',Obj{:},err.message);

end

end