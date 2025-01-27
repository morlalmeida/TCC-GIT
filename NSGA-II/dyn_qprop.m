function [Result2] = dyn_qprop
vel_design = 2; % m/s
RPM_op = 3000; 
file = 'qmil_inputfile'; 
motorfile = 'EMRAX228_LV'; % File containing motor info
%% ----------------------- Inputs for QPROP ------------------------------
propfile = 'prop.txt'; % File containing prop info = QMIL's output
outputfile = 'LastRun';
inputs =   {'Velocity'
            'RPM'
            'Voltage'
            'dBeta'
            'Thrust'
            'Torque'
            'Current'
            'Pele'};
j = 1;

for i = linspace(5,56,200)
        Setpoint.Velocity = i;    % Always define
        Setpoint.RPM      = RPM_op;
        Setpoint.Voltage  = [];
        Setpoint.dBeta    = 0.0;   % Leave as 0.0
        Setpoint.Thrust   = [];
        Setpoint.Torque   = [];
        Setpoint.Current  = [];
        Setpoint.Pele     = [];    % Leave Empty

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

    Result2.Velocity(j)           = i;
    Result2.Freestream(j)         = run_results.data(:,1);
    Result2.RPMs(j)               = run_results.data(:,2);
    Result2.Thrust(j)             = run_results.data(:,4);
    Result2.Torque(j)             = run_results.data(:,5);
    Result2.Voltage(j)            = run_results.data(:,7);
    Result2.Current(j)            = run_results.data(:,8);
    Result2.Pelectric(j)          = (run_results.data(:,16))/1000;

    delete([outputfile '.dat'])
    j = j+1;
end