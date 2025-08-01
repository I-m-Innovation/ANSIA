function plotQMean(app,Q,Time,MeanFlow2022);


if app.MediaAnnualeCheckBox.Value==1

    hold(app.Graph,'on');
    Qmean2022=MeanFlow2022*ones(length(Q),1);
    plot(app.Graph,Time,Qmean2022,'LineStyle','-.','Marker','none','LineWidth',2,'Color',[0.9290 0.6940 0.1250]);
    legend(app.Graph,{'Potenza istantanea','Potenza media','Portata istantanea','Portata media','Portata concessa','Portata Media 2023'},'location','best','Orientation','vertical', 'FontSize',10);

else

        legend(app.Graph,{'Potenza istantanea','Potenza media','Portata istantanea','Portata media','Portata concessa'},'location','best','Orientation','vertical', ...
    'FontSize',10);

end

end