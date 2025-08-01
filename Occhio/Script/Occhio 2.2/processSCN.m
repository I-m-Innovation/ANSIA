function     Data=processSCN(app,Plant)

try
    delete(app.errLabel)
end



try
    if app.Resize == 0
        try
            Data = uploadSCNData(app);
        catch err
            err.message
        end

        try
            plotSCN(app,Data);

            l=app.Tree.Position(3);
            h=app.Tree.Position(4);

            X=app.Graph.InnerPosition(1);
            Y=app.Graph.InnerPosition(2);
            lunghezza=app.Graph.InnerPosition(3);
            altezza=app.Graph.InnerPosition(4);

            app.Tree.Position(1)=X;
            app.Tree.Position(2)=Y+altezza-h;
            app.Tree.Visible="on";
            app.CurrData=Data;
        catch err
            err.message
        end
    else

        try

            plotSCN(app,app.CurrData);

        catch err
            err.message
        end

        Data=app.CurrData;
        app.Resize = 0;

    end

    app.NErr(:)=zeros(length(app.NErr));

catch err

    if err.message=="The connection to URL 'https://higeco-monitoraggio.it/api/v1/authenticate' timed out after 60.000 seconds. The reason is "+char(34)+"Waiting for response header"+char(34)+". Perhaps the server is not responding or weboptions.Timeout needs to be set to a higher value." && app.NErr(1)<=5

        app.ErrCode=1;
        app.NErr(app.ErrCode)=app.NErr(app.ErrCode)+1;

    else

        printError(app,err);
        Obj="DEBUG OCCHIO - "+string(Plant);
    end

end

try
    app.CurrPlant=Plant;

end

end