function errReport(app,error)
    setEmailOptions(app);

    Stacks=table2cell(struct2table(error.stack))
    
    IdRaw="Identifier: "+error.identifier;
    MessageRaw="Message: "+error.message;
    
    hStacks=height(Stacks);
    StacksRaw = "Stacks:"
    for i=1:hStacks
        StacksRaw = StacksRaw+newline+"  "+Stacks{i,1}+",    "+Stacks{i,2}+",    "+Stacks{i,3};
    end

    Text=IdRaw+newline+...
        MessageRaw+newline+...
        StacksRaw;



    Obj='DEBUG ANSIA';
    sendmail2('monitoraggio@zilioenvironment.com',Obj,Text{:});
    
end