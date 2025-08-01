function ReadData(app)

        try
%             SCNData=uploadSCNData(app);
%             RubinoData=uploadRubinoData(app);
            PGData=uploadPGData(app);
            STData=uploadSTData(app);
            PartitoreData=uploadPartitoreData(app);

%             SCNfileName=plotPV(app,SCNData,"SCN");
%             RubinofileName=plotPV(app,RubinoData,"Rubino");
            PGfileName=plotHydro(app,PGData,"Ponte Giurino");
            STfileName=plotHydro(app,STData,"San Teodoro");
            PartitorefileName=plotHydro(app,PartitoreData,"Partitore");
    
            sendMail(app,PGfileName,STfileName,PartitorefileName);
        end
      
end