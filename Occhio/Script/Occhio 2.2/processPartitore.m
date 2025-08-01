function     Data=processPartitore(app,Plant)

app.CurrPlant=Plant;
try
    delete(app.errLabel);
end

try
    if app.Resize==0

        try
            Data=uploadPartitoreData(app);
        catch err
            err
        end

        createCheckBox(app);
        try
            plotIdro(app,Data,Plant);
        catch err
            printError(app,err);
            err
        end

    else

        createCheckBox(app);
        try
            plotIdro(app,app.CurrData,app.CurrPlant);
        catch err
            err
            printError(app,err);

        end
        Data=app.CurrData;
        app.Resize=0;

    end

catch err

    printError(app,err);
    Obj="DEBUG OCCHIO - "+string(Plant);
    %     sendmail2('stefano.trevisan@zilioservice.com',Obj{:},err.message);

end

%plotNoLink(app,Data,"Partitore");


end