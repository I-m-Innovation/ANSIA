function switchStateLamp(app,Plant)

x=app.Graph.Title.Position(1);
y=app.Graph.Title.Position(2);

l=app.Graph.Position(3);
h=app.Graph.Position(4);
x=app.Graph.Position(1);
y=app.Graph.Position(2);

L=app.UIFigure.Position(3);
H=app.UIFigure.Position(4);

lLabel=L/5;
hLabel=H/20;
RLamp=hLabel;
cH=0.9*hLabel;
lTot=lLabel+RLamp;
d=lTot/10;

app.TitleLamp.Visible='on';
app.TitleLampLabel.Visible='on';
app.TitleLampLabel.Position=[L/2-lTot/2+RLamp 57*H/60 lLabel hLabel];
app.TitleLamp.Position=[L/2-(lTot+d)/2 57*H/60 RLamp RLamp];
app.TitleLampLabel.FontSize=cH;
app.TitleLampLabel.Text=string(Plant);

end