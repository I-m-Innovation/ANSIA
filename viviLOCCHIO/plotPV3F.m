function    plotPV3F(app,Data,Plant,isEmpty)

if isEmpty == 0
try
    cla(app.Graph);
end
end
try

    powTime=Data.timeStamp;
    PDC=Data.PowerDC;
    PAC=Data.PowerAC;
%     SolarTime=Data.SolarTime;
%     SolarValue=Data.SolarValue;
   
%     yyaxis(app.Graph,"left");
    plot1=plot(app.Graph,powTime,PAC,'LineWidth',1);
    ylabel(app.Graph,"Potenza AC [kW]");
%     hold(app.Graph,'on');
%     yyaxis(app.Graph,"right");
   
%     plot2=plot(app.Graph,SolarTime,SolarValue,'LineWidth',1);
%     ylabel(app.Graph,"Irraggiamento pesato [W/m^2]");

     hGraph=max(plot1.YData)+10;
%     hold(app.Graph,'on');

%     hold(app.Graph,'off');

    try
        setAxisLimits(app,hGraph);
    catch err
        Recipients="stefano.trevisan@zilioservice.com";
        TEXT="Errore in 'setXAxisLimits()'"+newline+string(err.message);
%         sendmail2(Recipients,"viviL'OCCHIO: problema con l'impostazione degli assi",TEXT{:});
    end
    try
    plotBackGround(app,Plant,hGraph);
    catch err
        Recipients="stefano.trevisan@zilioservice.com";
        TEXT="Errore in 'setXAxisLimits()'"+newline+string(err.message);
%         sendmail2(Recipients,"viviL'OCCHIO: problema con la stampa dello sfondo",TEXT{:});
    end

%     legend(app.Graph,{'Potenza AC'},'location','Best','FontSize',10,'Location','NorthEast');
    
end


end