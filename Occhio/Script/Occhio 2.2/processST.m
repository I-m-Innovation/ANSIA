function Data=processST(app,Plant)

app.CurrPlant=Plant;
try
    delete(app.errLabel)
end

try
    if app.Resize==0
        
        try
            Data=uploadSTData(app);

        end
            
%             Status=evaluateStatus(app,Data,Plant);

        try
            createCheckBox(app);
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

    app.NErr(:)=zeros(length(app.NErr));



catch err

    if err.message=="FTP error: 426. See FTP server return codes for more information." && app.NErr(1)<=5


        app.ErrCode=1;
        app.NErr(app.ErrCode)=app.NErr(app.ErrCode)+1;


    else

        printError(app,err);

        Obj="DEBUG OCCHIO - "+string(Plant);
%         sendmail2('stefano.trevisan@zilioservice.com',Obj{:},err.message);


    end

end
