function PlotH2OPower(app,Time,P,PMean)

yyaxis(app.Graph,'left');
ylabel(app.Graph,"Potenza [kW]","FontSize",15);
area(app.Graph,Time,P,'FaceAlpha',0.5);

minP=min(min(P),min(P));
maxP=max(max(P),max(P));

if min(P) + max(P) ~= 0

    ylim(app.Graph,[minP-0.01*minP maxP+0.01*maxP]);

else

    ylim(app.Graph,[0 1]);

end

hold(app.Graph,'on');
plot(app.Graph,Time,PMean,'LineStyle','-','Marker','none','LineWidth',3);

end
