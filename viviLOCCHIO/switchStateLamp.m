function switchStateLamp(app)
l=app.Graph.Position(3);
h=app.Graph.Position(4);
x=app.Graph.Position(1);
y=app.Graph.Position(2);

L=app.UIFigure.Position(3);
H=app.UIFigure.Position(4);

app.ConnectionstateLamp.Position=[l (h+(H-h)/2) 20 20];
app.ConnectionstateLamp.Visible='on';
app.ConnectionstateLampLabel.Visible='on';
app.ConnectionstateLampLabel.Position=[l-120 (h+(H-h)/2) 100 20];
end