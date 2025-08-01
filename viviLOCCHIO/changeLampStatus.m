function changeStateLampStatus(app,Color,State)

        app.NErr(:)=zeros(length(app.NErr));
        app.ConnectionstateLamp.Color=Color;
        app.ConnectionstateLampLabel.Text=State;

end