function refreshEffLabel(app,Data,Type,Name)

try
    delete(app.effLabel);
end

app.effLabel=uilabel(app.UIFigure);
app.effLabel.Interpreter='tex';
fontname(app.effLabel,"Consolas");
app.effLabel.Text="";

if Type=="hydro"

    Q=Data.Flow;

    Pr=Data.Pressure;

    P=Data.Power;
    rho=1000;
    g=9.81;
    h1bar=10.1974;

    if Name == "Torrino Foresta" || Name == "SA3"
        Q = Q*1000;
    end

    eta=P(end)/(rho*g*h1bar*Pr(end)*Q(end))*1e6;

    if isnan(eta)==1

        eta=0;

    end

    app.effLabel.Text="\eta = "+string(round(eta*100,3,"significant"))+" %";

elseif Type=="PV"

    Irr=Data.irrValue(end);
    if Name=="SCN - Pilota"
    Power=Data.PTot(end);
    else
    Power=Data.powValue(end);
    end
    if Name=="SCN - Pilota"
        Pp=926.64;
    elseif Name=="Rubino"
        Pp=997.92;
    end

    PR=Power/Irr*1000/Pp;
    app.effLabel.Text="PR = "+string(round(PR*100,3,"significant"))+" %";

end


xGraphStart=app.Graph.InnerPosition(1);
yGraphStart=app.Graph.InnerPosition(2);
L=app.Graph.InnerPosition(3);
H=app.Graph.InnerPosition(4);

l=L/6;
h=l;

xLabelStart=xGraphStart+L-l;
yLabelStart=yGraphStart;
app.effLabel.Position=[xLabelStart yGraphStart l h];

app.effLabel.BackgroundColor='r';
app.effLabel.FontSize=0.15*l;
app.effLabel.FontColor='w';
% app.effLabel.FontWeight='bold';
app.effLabel.HorizontalAlignment='center';
app.effLabel.VerticalAlignment='center';

end