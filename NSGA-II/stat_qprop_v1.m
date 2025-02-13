function [Result1] = stat_qprop
vel_design = 2; % m/s
RPM_op = 3000; 
file = 'qmil_inputfile'; 
motorfile = 'EMRAX228_LV'; % File containing motor info
%% ------------------------------QMIL--------------------------------------
% commandstring = ['qmil ' file ...
%                   '  propfile_qmil  '];
% system(commandstring);

%% ----------------------- Inputs for QPROP ------------------------------
propfile = 'prop.txt'; % File containing prop info = QMIL's output
outputfile = 'LastRun1';
inputs =   {'Velocity'
            'RPM'
            'Voltage'
            'dBeta'
            'Thrust'
            'Torque'
            'Current'
            'Pele'};
j = 1; 
%% -------------------------- Set for static ------------------------------
    for i = linspace(1000,3000,40)
        Setpoint.Velocity = vel_design;    % Always define
        Setpoint.RPM      = i;
        Setpoint.Voltage  = [];
        Setpoint.dBeta    = 0.0;           % Leave as 0.0
        Setpoint.Thrust   = [];
        Setpoint.Torque   = [];
        Setpoint.Current  = [];
        Setpoint.Pele     = [];            % Leave Empty

    SetpointString = [];
        for n=1:numel(inputs)
        if isempty(Setpoint.(inputs{n}))==1
            SetpointString = [SetpointString ' 0'];
        else    
            SetpointString = [SetpointString ' ' num2str(Setpoint.(inputs{n}))];
        end
        end


    commandstring = ['qprop.exe ' propfile ...
                     ' InputDataFiles\' motorfile ...
                     SetpointString ' > ' outputfile '.dat'];
    system(commandstring);

    run_results = importdata( [outputfile '.dat'],' ',17);

    Result1.Velocity(j)           = vel_design;
    Result1.Freestream(j)         = run_results.data(:,1);
    Result1.RPMs(j)               = run_results.data(:,2);
    Result1.Thrust(j)             = run_results.data(:,4);
    Result1.Torque(j)             = run_results.data(:,5);
    Result1.Voltage(j)            = run_results.data(:,7);
    Result1.Current(j)            = run_results.data(:,8);
    Result1.Pelectric(j)          = (run_results.data(:,16))/1000;

    delete([outputfile '.dat'])
    j = j +1;
    end
end