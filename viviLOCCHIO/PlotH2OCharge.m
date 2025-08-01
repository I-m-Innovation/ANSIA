function PlotH2OCharge(app,Time,Q,QMean,QConc)

yyaxis(app.Graph,'right');

if isempty(QConc)==0

minQ=min(min(Q),min(QConc));
maxQ=max(max(Q),max(QConc));

else

    minQ=min(Q);
    maxQ=max(Q);

end

if min(Q)+ max(Q)~= 0

    ylim(app.Graph,[minQ-0.01*minQ maxQ+0.01*maxQ]);

elseif min(Q)+ max(Q)== 0

    ylim(app.Graph,[0 mean(QConc)+0.01*mean(QConc)]);


end

ylabel(app.Graph,"Portata [l/s]","FontSize",15);
hold(app.Graph,'on');

plot(app.Graph,Time,Q,'Marker','none','LineStyle','-');
    


hold(app.Graph,'on');
plot(app.Graph,Time,QMean,'LineStyle','-','Marker','none','LineWidth',3);

if isempty(QConc)==0
hold(app.Graph,'on');
plot(app.Graph,Time,QConc,'LineStyle','-','Marker','none','LineWidth',2,'Color','green');
end

end