function plotLegend(Graph,data)

    if app.MediaAnnualeCheckBox.Value==0
        
        legend(Graph,{'Potenza istantanea','Potenza media','Portata istantanea','Portata media','Portata concessa'},'location','best','Orientation','vertical', ...
    'FontSize',10);
    else
        legend(app.Graph,{'Potenza istantanea','Potenza media','Portata istantanea','Portata media','Portata concessa','Portata Media 2023'},'location','best','Orientation','vertical', 'FontSize',10);

    end



end