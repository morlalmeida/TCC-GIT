function [Result1] = stat_qprop
    vel_design = 2; % m/s
    RPM_range = linspace(200, 4000, 100); % RPM values
    num_RPMs = numel(RPM_range);

    propfile = 'prop.txt'; % File containing prop info
    motorfile = 'EMRAX228_LV'; % File containing motor info
    outputfile = 'LastRun1';

    % Preallocate arrays (MATLAB does not allow struct field modification in parfor)
    Velocity = zeros(1, num_RPMs);
    Freestream = zeros(1, num_RPMs);
    RPMs = zeros(1, num_RPMs);
    Thrust = zeros(1, num_RPMs);
    Torque = zeros(1, num_RPMs);
    Voltage = zeros(1, num_RPMs);
    Current = zeros(1, num_RPMs);
    Pelectric = zeros(1, num_RPMs);

    % Use parallel loop
    parfor j = 1:num_RPMs
        i = RPM_range(j);

        % Generate unique output filename per worker
        temp_outputfile = [outputfile '_' num2str(j) '.dat'];

        % Construct setpoint string explicitly (avoid struct inside parfor)
        SetpointString = sprintf(' %f %f 0 0 0 0 0 0', vel_design, i);

        % Run QPROP
        commandstring = ['qprop.exe ' propfile ...
                         ' InputDataFiles\' motorfile ...
                         SetpointString ' > ' temp_outputfile];
        system(commandstring);

        % Read results
        run_results = importdata(temp_outputfile, ' ', 17);

        % Store results in temporary arrays
        Velocity(j) = vel_design;
        Freestream(j) = run_results.data(:,1);
        RPMs(j) = run_results.data(:,2);
        Thrust(j) = run_results.data(:,4);
        Torque(j) = run_results.data(:,5);
        Voltage(j) = run_results.data(:,7);
        Current(j) = run_results.data(:,8);
        Pelectric(j) = run_results.data(:,16) / 1000;

        % Cleanup
        delete(temp_outputfile);
    end

    % Assign results to struct AFTER parfor loop
    Result1.Velocity = Velocity;
    Result1.Freestream = Freestream;
    Result1.RPMs = RPMs;
    Result1.Thrust = Thrust;
    Result1.Torque = Torque;
    Result1.Voltage = Voltage;
    Result1.Current = Current;
    Result1.Pelectric = Pelectric;
end
