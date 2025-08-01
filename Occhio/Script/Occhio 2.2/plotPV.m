function    plotPV(app,Data,Plant)

try
    cla(app.Graph);
catch err
    err
end

            try

                
                irrTime=Data.irrTime;
                powTime=Data.powTime;
                irrValue=Data.irrValue;
                powValue=Data.powValue;
                
                colororder(app.Graph,[0.8500 0.3250 0.0980; 0.6350 0.0780 0.1840]);
                plotPVPower(app,powTime,powValue);
                maxVal = max(powValue);
                setAxisLimits(app,maxVal);

%                 setXAxisLimits(app);

                hold(app.Graph,'on');
                plotPVRad(app,irrTime,irrValue);

                legend(app.Graph,{'Potenza','Irraggiamento'},'location','Best','FontSize',10);

                
%                 hold(app.Graph,'off');

            catch err

                 err
                

            end

end