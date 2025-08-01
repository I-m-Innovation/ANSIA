function PlotH2OPower(app,Time,P,PMean,Producibile,Plant)

yyaxis(app.Graph,'left');
ylabel(app.Graph,"Potenza [kW]","FontSize",15);

area(app.Graph,Time,P,'FaceAlpha',0.5);

if Plant == "Torrino Foresta"

    PMax = 440;


elseif Plant =="Ponte Giurino"

    PMax = 235;
elseif Plant == "San Teodoro"

    PMax = 259;

elseif Plant == "Partitore"

    PMax = 100;

elseif Plant == "SA3"

    PMax = 250;
end


minP=min(0,min(P));
maxP=max(PMax,max(P));
ylim(app.Graph,[minP maxP]);


tOn = Time(1,1);
tOff = tOn+hours(24);

hold(app.Graph,'on');
% plot(app.Graph,Time,Producibile,'LineStyle','--','Marker','none','LineWidth',1);
% 
% hold(app.Graph,'on');

plot(app.Graph,Time,PMean,'LineStyle','-','Marker','none','LineWidth',3);



end
