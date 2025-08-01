function [nameFile, L, H]=createPlot(Data,Plant,Type)

fig=figure('Visible','off');
ax1=axes(fig);

if Plant == "TF"

    Title = "Torrino Foresta";
    maxP = 249;
    QConc = 1.54;

elseif Plant == "PG"

    Title = "Ponte Giurino";
    maxP = 200;
    QConc = 70;

elseif Plant == "Partitore"

    Title = "Partitore";
    maxP = 84.86;
    QConc = 25;

elseif Plant == "ST"

    Title = "San Teodoro";
    maxP = 238.30;
    QConc = 70;
    
elseif Plant == "SCN"

    Title = "SCN Pilota";
    maxP = 926.64;

else

    Title = Plant;
    maxP = 997.44;
end

title(ax1,Title)

if Type=="PV"
    colororder(ax1,[0.8500 0.3250 0.0980; 1 0 0]);

    yyaxis(ax1,'left');
    area(ax1,Data.powTime,Data.powValue,'FaceAlpha',0.5);
    ylim(ax1,[0,max(max(Data.powValue), maxP)]);
    
else

    colororder(ax1,[0.3010 0.7450 0.9330;0.4660 0.6740 0.1880]);
    yyaxis(ax1,'left');
    area(ax1,Data.timeStamp,Data.Power,'FaceAlpha',0.5);
    ylim(ax1,[0,max(max(Data.Power), maxP)]);

end
    ylabel(ax1,"Potenza [kW]");

hold(ax1,'on');
yyaxis(ax1,'right');

if Type=="PV"

    plot(ax1,Data.irrTime,Data.irrValue,'LineWidth',1);
    ylabel(ax1,"Irraggiamento [W/m^2]");
    ylim(ax1,[0,max(max(Data.irrValue),1300)]);

%     legend(ax1,["Potenza istantanea","Irraggiamento istantaneo"],'Location','northeast');

else

    plot(ax1,Data.timeStamp,Data.Flow,'LineWidth',1);
    ylabel(ax1,"Portata [L/s]");
    ylim(ax1,[0,max(max(Data.Flow), QConc)]);

    if Plant == "TF"
            ylabel(ax1,"Portata [m^3/s]");
    end
%     legend(ax1,["Potenza istantanea","Portata istantanea"],'Location','northeast');
end

xlim(ax1,[datetime('Today'),datetime('tomorrow')]);
grid(ax1,'on');
hold(ax1,'off');

nameFile=Plant+round(posixtime(datetime('now')))+".png";
saveas(ax1,nameFile);
L=ax1.Position(3);
H=ax1.Position(4);

end