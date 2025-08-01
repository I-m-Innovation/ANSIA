function             refreshEffLabelAfterResizing(app)

    
    xGraphStart=app.Graph.InnerPosition(1);
    yGraphStart=app.Graph.InnerPosition(2);
    L=app.Graph.InnerPosition(3);
    H=app.Graph.InnerPosition(4);

    l=L/10;
    h=l;
    
    xLabelStart=xGraphStart+L-l;
    yLabelStart=yGraphStart;
    app.effLabel.Position=[xLabelStart yGraphStart l h];

end