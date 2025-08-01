function refreshEffText(app,Data,Plant)

try
    app.ann.String="";
end

X0=app.UIFigure.Position(1);
Y0=app.UIFigure.Position(2);
L=app.UIFigure.Position(3);
H=app.UIFigure.Position(4);

x0=app.Graph.InnerPosition(1);
y0=app.Graph.InnerPosition(2);
l=app.Graph.InnerPosition(3);
h=app.Graph.InnerPosition(4);

lambda=l/6;
theta=h/6;

if Plant=="HONDA"




    txt="Rendimenti Inverter:"+newline+"Gate 1: "+string(round(Data.eta_HONDA1*100,3,"significant"))+" %"+newline+ ...
         "Gate 2: "+string(round(Data.eta_HONDA2*100,3,"significant"))+" %"+newline+ ...
         "Tetto: "+string(round(Data.eta_HONDA3*100,3,"significant"))+" %";
    


else



    txt="Rendimenti Inverter:"+newline+"Ferro: "+string(round(Data.eta_FERRO*100,3,"significant"))+" %"+newline+ ...
         "Plastica: "+string(round(Data.eta_PLASTICA*100,3,"significant"))+" %";   

end

app.ann=annotation(app.UIFigure,'textbox','String',txt);
    app.ann.Position=[(x0+30)/L (y0+h-theta-h/20)/H lambda/L theta/H];
    app.ann.LineStyle="none";    
