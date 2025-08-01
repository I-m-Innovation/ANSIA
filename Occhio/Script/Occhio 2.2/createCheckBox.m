function createCheckBox(app)

    app.MediaAnnualeCheckBox.Visible='on';
    L=app.UIFigure.Position(3);
    H=app.UIFigure.Position(4);

    l=app.Graph.Position(3);
    h=app.Graph.Position(4);

    margVert=(H-h)/2;
    margHor=(L-l)/2;

    app.MediaAnnualeCheckBox.Position=[margHor margVert/2-10 300 20];
    app.MediaAnnualeCheckBox.Text="Mostra media annuale";
    app.MediaAnnualeCheckBox.Value=0;

end