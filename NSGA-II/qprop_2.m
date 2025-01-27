%% Integração MATLAB <-> QPROP/QMIL
% Paulo Henrique Farah 
% paulo.farah@moya-aero.com
% 07-03-24

%% ------------------------------ INPUTS -----------------------------------
clc,clear
plot = 0;
dyn = 1; % Boolean for dynamic data
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
%% -------------------------- Set for static ------------------------------
    for i = 1000:50:6500
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
    %% Plots 
    if plot == 1
    figure (1)
    plot(Result1.RPMs,Result1.Thrust,'-','LineWidth',1)
    grid minor
    xlabel ('RPM')
    ylabel ('Thrust (N)')

    figure (2)
    plot(Result1.RPMs,Result1.Pelectric,'-','LineWidth',1)
    grid minor
    xlabel('RPM')
    ylabel('P_{electrical} (kW)')
    end
%% --------------------------- Set for dynamic ----------------------------
    for i = linspace(5,56,100)
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
    %% Plots
    if plot == 1;
    figure (3)
    plot(Result2.Velocity,Result.Thrust,'-','LineWidth',1)
    grid minor
    xlabel ('V [m/s]')
    ylabel ('Thrust (N)')

    figure (4)
    plot(Result2.Velocity,Result2.Pelectric,'-','LineWidth',1)
    grid minor
    xlabel('V [m/s]')
    ylabel('P_{electrical} (kW)')
    end
    
    save('prop_res','Result1','Result2') 

% Calling script for required x available power/thrust
  power_thrust(Result2)
%   ceilings(Result)