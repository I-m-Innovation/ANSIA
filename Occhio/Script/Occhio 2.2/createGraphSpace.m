function createGraphSpace(app,Plant)

L = app.UIFigure.Position(3);
H = app.UIFigure.Position(4);

margineHor = L / 20;
margineVer = H / 20;

l = L - 2 * margineHor;
h = H - 2 * margineVer;

if app.FirstStart == 1
    app.Graph = uiaxes( app.UIFigure );
end

app.Graph.Position = [margineHor margineVer l h];
% title( app.Graph, string(Plant), "FontSize", 25);

app.Graph.FontName = 'Times';
app.Graph.XGrid = 'off';
app.Graph.XMinorGrid = 'off';
app.Graph.YGrid = 'on';
app.Graph.GridColor='k';
app.Graph.GridAlpha=0.05;
app.Graph.Box = 'on';


end
