function Timer=setTimer(app,Plant)

Timer=timer(...
                'ExecutionMode', 'fixedRate', ...      % Run timer repeatedly
                'Period', 60, ...                       % Period is 3 minutes
                'BusyMode', 'queue',...                % Queue timer callbacks when busy
                'TimerFcn', @(isFirst,varargin) RefreshData(app,Plant));   % Callback that runs every period
end