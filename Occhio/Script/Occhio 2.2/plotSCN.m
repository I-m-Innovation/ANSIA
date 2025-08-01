function plotSCN(app,Data)

try
    cla(app.Graph);
end


try

    if isgraphics(app.Graph)==0

        app.Graph = uiaxes( app.UIFigure );
        createGraphSpace(app,"SCN - Pilota");

        try
            app.errLabel.Text="";

        end

    end
    checked=string({app.Tree.CheckedNodes.Text});


    if find(checked=="Sezione 1")>0

        if find(checked=="Sezione 2")>0
            Sec="SCN";
            plotPVPower(app,Data.TTot,Data.PTot);
        else

            Sec="SCN1";
            plotPVPower(app,Data.T1,Data.P1);
        end

    elseif find(checked=="Sezione 2")==1

        if find(checked=="Sezione 1")==1

            Sec="SCN";
            plotPVPower(app,Data.TTot,Data.PTot);

        else

            Sec="SCN2";
            plotPVPower(app,Data.T2,Data.P2);

        end




    else

        cla(app.Graph);
        printError(app,"Nessuna sezione selezionata!");

    end

    maxVal = max(Data.PTot);
    setAxisLimits(app,maxVal);

    hold(app.Graph,"on");
    plotPVRad(app,Data.irrTime,Data.irrValue)
    legend(app.Graph,{'Potenza','Irraggiamento'},'location','Best','FontSize',10);



    plotNoLink(app,Data,Sec);

    hold(app.Graph,"off");

catch

    delete(app.Graph);
%     printError(app,"Nessuna sezione selezionata!");
end



end