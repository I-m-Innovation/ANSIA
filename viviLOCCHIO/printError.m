function printError(app,error)

% try
%     cla(app.Graph);
% end

try
        app.errLabel.Text="";

end
L=app.UIFigure.Position(3);
H=app.UIFigure.Position(4);

l=300;
h=500;

app.errLabel=uilabel(app.UIFigure);
app.errLabel.Position=[L/2-l/2 H/2-h/2 l h];
app.errLabel.FontColor='r';
app.errLabel.FontWeight='bold';
app.errLabel.WordWrap = "on";

app.errLabel.FontSize=20;
app.errLabel.Text=error;
end