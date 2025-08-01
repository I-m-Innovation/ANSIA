function plotPVRad(app,irrTime,irrValue)

yyaxis(app.Graph,'right');
plot(app.Graph,irrTime,irrValue,'Color',[0.6350 0.0780 0.1840],'LineStyle','-','Marker','none');
ylabel(app.Graph,"Irraggiamento [W/m^2]",'FontSize',15);
ylim(app.Graph,[0,max(1300, max(irrValue))]);

end