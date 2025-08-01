function PlotH2OCharge(app,Time,Q,QMean,QConc,Name)

yyaxis(app.Graph,'right');


if Name == "Torrino Foresta"

    QMax = 1.56;

elseif Name == "Ponte Giurino" || Name == "San Teodoro"
    QMax = 80;
elseif Name == "Partitore"
    QMax = 25;
end




minQ=min(Q);
maxQ=max(Q);



ylim(app.Graph,[min(0, minQ) max(QMax,maxQ)]);

if Name=="Torrino Foresta"

    ylabel(app.Graph,"Portata [m^3/s]","FontSize",15);

else

    ylabel(app.Graph,"Portata [l/s]","FontSize",15);

end
hold(app.Graph,'on');

plot(app.Graph,Time,Q,'Marker','none','LineStyle','-');



hold(app.Graph,'on');
plot(app.Graph,Time,QMean,'LineStyle','-','Marker','none','LineWidth',3);

if isempty(QConc)==0
    hold(app.Graph,'on');
    plot(app.Graph,Time,QConc,'LineStyle','-','Marker','none','LineWidth',2,'Color','green');
end

end