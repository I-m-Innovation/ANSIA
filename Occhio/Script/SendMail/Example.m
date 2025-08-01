

% Example of how to send an email with HTML formatting using sendmail2.m.
%
% ABOUT - The default Matlab function sendmail.m is used to send email/text
% messages from Matlab. However, it is not possible to include HTML
% formatting in the body to spice up the message. As a solution to this
% problem I found a post on UndocumentedMatlab.com [Reference-1] which
% implements this feature. The function sendmail2.m has been modified using
% the code of Matlab 2016b. An alternative is to use Outlook, see
% [Reference-2].


% -------------------------------------------------------------------------
% 1. Download sendmail2.m and store it in your workspace


% -------------------------------------------------------------------------
% 2. Find your outgoing SMTP server address in your email account settings
% in your email client application. You can also contact your system
% administrator for the information. In some cases you might need to setup
% the STMP procol first. Read more here:
% https://nl.mathworks.com/help/matlab/import_export/sending-email.html


% -------------------------------------------------------------------------
% 3. Apply the following settings:

% Email address: This preference sets your email address that will appear on the message.
setpref('Internet','E_mail','youraddress@yourserver.com');

% SMTP server: This preference sets your outgoing SMTP server address,
% which can be almost any email server that supports the Post Office
% Protocol (POP) or the Internet Message Access Protocol (IMAP).
setpref('Internet','SMTP_Server','mail.server.network');


% -------------------------------------------------------------------------
% 4. Send the email with HTML

% Html
htmlBody    = '<p><strong style="color: red">Hello</strong><span style="color:blue"> from Matlab</span></p></p>Example of a <b>HTML</b> body</p>';
attachments = {'dummy-attachment.txt'};

% Subject + body
sendmail2('recipient@someserver.com','An email with HTML formatting!', htmlBody);

% Subject + body + attachments
sendmail2('recipient@someserver.com','An email with HTML formatting + attachments', htmlBody, attachments);

