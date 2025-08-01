function plotBackGround(app,Plant,H)


if Plant=="HONDA"

    img=imread('2552px-Honda_Logo.svg.png');
    [altezza,base]=size(img);
    % image(app.Graph,'CData',img,'XData',[1/10 9/10],'AlphaData',0.05);
    image(app.Graph,'CData',img,'XData',[1/10 9/10],'YData',[H 0],'AlphaData',0.05);

elseif Plant=="3F"

    [img, ~, tr]=imread('Logo3F8.jpg');
    im=image(app.Graph,'CData',img,'XData',[2/5 3/5],'YData',[3*H/5 2*H/5],'AlphaData',0.005);
    im.AlphaData=tr;

end



end