function plotPVPower(app,powTime,powValue)

area(app.Graph,powTime,powValue,'FaceAlpha',0.5,'FaceColor','r','EdgeColor','none');
ylabel(app.Graph,"Potenza [kW]",'FontSize',15);

end