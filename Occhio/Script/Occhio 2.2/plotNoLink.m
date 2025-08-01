function plotNoLink(app,Data,Sec)

yMax=app.Graph.YLim(2);

if Sec=="SCN"
    Fermi=Data.FermiTot;
elseif Sec=="SCN1"
    Fermi=Data.Fermi1;
elseif Sec=="SCN2"
    Fermi=Data.Fermi2;
elseif Sec=="Rubino"
    Fermi=Data.Fermi;
elseif Sec=="Partitore"
    Fermi=Data.NoLinkIntervals;
else
    Fermi=Data.NoLinkIntervals;

end

try
    clear app.NoLinkBar;
end


for i=1:height(Fermi)

    x=[Fermi(i,1) Fermi(i,2) Fermi(i,2) Fermi(i,1)];
    y=[0 0 yMax yMax];
    hold(app.Graph,'on')
    app.NoLinkBar = fill(app.Graph,x,y,[0.2 0.2 0.2],'LineStyle','none','FaceAlpha',0.5);


end
end