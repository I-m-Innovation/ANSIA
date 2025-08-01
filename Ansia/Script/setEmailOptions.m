function [Recipients,  mailObj]=setEmailOptions(app)

ContactList=readtable('Contatti.csv');
DestinatariSpuntati=string({app.Tree.CheckedNodes.Text}');

for i=1:length(DestinatariSpuntati)
    Recipients(i)=ContactList.Mail(ContactList.Nome==DestinatariSpuntati(i));
end

mailObj="L'ANSIA delle "+string(datetime('now','Format','HH:mm'));
setpref('Internet','E_mail','monitoraggio@zilioenvironment.com');
setpref('Internet','SMTP_Server','mail.webcloud.it');
setpref('Internet','SMTP_Username', 'monitoraggio@zilioenvironment.com');
setpref('Internet','SMTP_Password', 'Grlp091&0');
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty( 'mail.smtp.starttls.enable', 'true' );
props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port','465');

end