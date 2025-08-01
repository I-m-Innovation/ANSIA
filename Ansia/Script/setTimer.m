function Timer=setTimer(app)

dt=app.DeltatEditField.Value
Timer=timer(...
    'ExecutionMode', 'fixedRate', ...      % Run timer repeatedly
    'Period',dt*60, ...                       % Period is 3 minutes
    'BusyMode', 'queue',...                % Queue timer callbacks when busy
    'TimerFcn', @(varargin) ReadData(app));   % Callback that runs every period

end