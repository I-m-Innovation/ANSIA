function plotHSI(app,Data)

try
    cla(app.Graph);
end
                    
            try
                ProdTime=Data.powProdTime;
                ProdValue=Data.powProdValue;

                area(app.Graph,ProdTime,ProdValue,'FaceAlpha',1,'FaceColor',[0.9290 0.6940 0.1250]);
                hold(app.Graph,'on');

                AutoConsTime=Data.powAutoConsTime;
                AutoConsValue=Data.powAutoCons;
                area(app.Graph,AutoConsTime,AutoConsValue,'FaceAlpha',0.75,'FaceColor',[0.8500 0.3250 0.0980]);

                ylabel(app.Graph,"Potenza [kW]",'FontSize',15);

                hold(app.Graph,'off');
                legend(app.Graph,{'Potenza Prodotta','Potenza Autoconsumata'},'location','Best','FontSize',10);
                setXAxisLimits(app);
            end
end