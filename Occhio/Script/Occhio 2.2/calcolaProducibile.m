function producibile = calcolaProducibile(Flow, Pressure)
    
    RendTab=readtable("RendimentiH.csv");
    QRif=RendTab.QNew;
    dQ=(QRif(2)-QRif(1))/2;
    
    etaRif=RendTab.etaRif;
    etaRif(isnan(etaRif))=0;

    Q = Flow;
    h = Pressure*10.1974;
    producibile=zeros(length(Q),1);
    
    for i=1:length(Q)
        j=1;
        ok=0;
        while ok==0
            
            if Q(i)>=QRif(j)-dQ && Q(i)<QRif(j)+dQ
                ok=1;
                etaCurr=etaRif(j);
            else
                j=j+1;
            end

        end

        producibile(i,1) = 9.08665*Q(i)*h(i)*etaCurr/1000;

    end

end