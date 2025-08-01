function plotPVPower(app,powTime,powValue)

yyaxis(app.Graph,'left');
area(app.Graph,powTime,powValue,'FaceAlpha',0.5,'FaceColor',[0.8500 0.3250 0.0980]);
ylabel(app.Graph,"Potenza [kW]",'FontSize',15);

end