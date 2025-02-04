function [Result2] = dyn_qprop
    %% Define Constants
    vel_design = 2; % m/s
    RPM_op = 3000;
    file = 'qmil_inputfile';
    motorfile = 'EMRAX228_LV'; % File containing motor info

    % Input and Output Files
    propfile = 'prop.txt'; % File containing prop info
    outputfile = 'LastRun2';

    % Define velocity range
    velocity_range = linspace(5, 60, 300); % 300 test points

    % Ensure Parallel Pool is Active (Limit to 5 Workers)
    poolobj = gcp('nocreate');
    if isempty(poolobj)
        parpool(5); % Start parallel pool with 5 workers
    end

    % Number of velocity points
    N = length(velocity_range);

    % Preallocate Output as Arrays (Required for `parfor`)
    Velocity = zeros(N, 1);
    Freestream = zeros(N, 1);
    RPMs = zeros(N, 1);
    Thrust = zeros(N, 1);
    Torque = zeros(N, 1);
    Voltage = zeros(N, 1);
    Current = zeros(N, 1);
    Pelectric = zeros(N, 1);

    %% 🔹 Run QPROP in Parallel
    parfor j = 1:N
        % Extract velocity for this iteration
        i = velocity_range(j);

        % Generate input string (Avoid modifying struct inside `parfor`)
        SetpointString = sprintf(' %f %d 0.0 0 0 0 0 0', i, RPM_op);

        % Execute QPROP Command (Use unique output file per worker)
        outputfile_j = [outputfile num2str(j) '.dat'];
        commandstring = sprintf('qprop.exe %s InputDataFiles\\%s %s > %s', ...
                                propfile, motorfile, SetpointString, outputfile_j);
        system(commandstring);

        % Read QPROP Results
        try
            run_results = importdata(outputfile_j, ' ', 17);
            Velocity(j) = i;
            Freestream(j) = run_results.data(:, 1);
            RPMs(j) = run_results.data(:, 2);
            Thrust(j) = run_results.data(:, 4);
            Torque(j) = run_results.data(:, 5);
            Voltage(j) = run_results.data(:, 7);
            Current(j) = run_results.data(:, 8);
            Pelectric(j) = (run_results.data(:, 16)) / 1000;
        catch ME
            warning("Error in QPROP execution for velocity %.2f: %s", i, ME.message);
        end

        % Delete temporary output file
        delete(outputfile_j);
    end

    % Store Results in Struct after `parfor`
    Result2.Velocity = Velocity;
    Result2.Freestream = Freestream;
    Result2.RPMs = RPMs;
    Result2.Thrust = Thrust;
    Result2.Torque = Torque;
    Result2.Voltage = Voltage;
    Result2.Current = Current;
    Result2.Pelectric = Pelectric;
end
