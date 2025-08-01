function     Data=processPG(app,Plant)

    app.CurrPlant=Plant;
    Recipients="monitoraggio@zilioenvironment.com";

try
    delete(app.errLabel)
end

try
    if app.Resize==0
        try
            Data=uploadPGData(app);
        catch err
            TEXT="Errore in 'uploadPGData()'"+newline+string(err.message);
%             sendmail2(Recipients,"DEBUG de L'OCCHIO",TEXT{:});
        end
        
        createCheckBox(app);

        try
            plotIdro(app,Data,Plant);
        catch err
            printError(app,err);
        end
    else

        createCheckBox(app);

        try
            plotIdro(app,app.CurrData,app.CurrPlant);
        catch err
            printError(app,err);
        end

        Data=app.CurrData;

        app.Resize=0;

    end

catch err

    printError(app,err);
    Obj="DEBUG OCCHIO - "+string(Plant);
%     sendmail2('monitoraggio@zilioenvironment.com',Obj{:},err.message);

end
%         plotNoLink(app,Data,"PG");

end