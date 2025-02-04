function fitness = evaluatefitness(x)
%% Setting Initial Parameters    
    M = 2; % Number of objectives
    fitness = [1e10, 1e10]; % Default to infeasible output in case of error;

    Diameter = x(1);
    Pitch = x(2);
    Nblades = floor(x(3));
    RPM_op = 3000;

%% Checking Tip Speed Conformity
    R = (Diameter/39.37) / 2; % Radius (m)
    omega = RPM_op * 2 * pi / 60; % Angular velocity (rad/s)
    TipSpeed = omega * R; % Tip speed (m/s)
    MaxTipSpeed = 340; % Maximum tip speed (m/s)
    if TipSpeed > 0.9*MaxTipSpeed
        % Constraint violated
        fitness = [1e10, 1e10]; % Penalize infeasible solution
        fprintf('The tip speed is higher than the Mach threshold!\n')
        fprintf('Mach: %.2f\n',  TipSpeed/MaxTipSpeed)
        return;
    end

 %% Running QPROP, Thrust and Flight Speed
    try
        prop_wrV1(x)                            % Generating Propller Archive
        % delete('LastRun.dat')
        [Result1] = stat_qprop;                 % Running Static QPROP - Hover
        hover_thrust = 4*Result1.Thrust;
        thrust_index = hover_thrust/(870*9.787);

        if thrust_index < 1.4
            return
        end

        % delete('LastRun.dat')                   
        [Result2] = dyn_qprop;                  % Running Dynamic QPROP - Cruise
        [fspeed,Vs] = power_thrust(Result2);    % Obtaining Flight Speed

 %% Thrust and Flight Speed Constraints 
        i = 1;
        if isscalar(fspeed)                     % Obtaining reliable Flight Speed
            if fspeed > Vs
                fspeed_true = fspeed;
            end
        elseif length(fspeed) > 1
            for i = 1:length(fspeed)
                if fspeed(i) <= Vs
                    continue
                elseif fspeed(i) > Vs
                    fspeed_true = fspeed(i);
                    break
                end
            end
        end

        if 0.8*fspeed_true <= Vs                 % Cheching Stall Speed Constraint
            fprintf('The flight speed is lower than the stall speed!\n')
            fprintf('Flight Speed: %.2f\n', 0.8*fspeed_true)
           return
        end

%% Genererating Fitness Vector
        fitness(1) = -(thrust_index);
        fitness(2) = -(0.8*fspeed_true/Vs);
    catch
    end