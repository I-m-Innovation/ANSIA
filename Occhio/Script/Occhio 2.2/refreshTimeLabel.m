function refreshTimeLabel(app)

    app.lastRefreshLabel.Text="";


    app.lastRefreshLabel=uilabel(app.UIFigure);
    L=app.UIFigure.Position(3);
    H=app.UIFigure.Position(4);

    l=app.Graph.Position(3);
    h=app.Graph.Position(4);
    
    margVert=(H-h)/2;
    margHor=(L-l)/2;
    app.lastRefreshLabel.Position=[l+margHor-300 margVert/2-10 300 20];
    app.lastRefreshLabel.Text="Last refresh: "+string(datetime('now'));

end