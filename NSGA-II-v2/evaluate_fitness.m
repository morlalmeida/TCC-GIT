function [fitness] = evaluate_fitness(x)
    %% Load Global Parameters
    global Vs MTOW;

    %% Setting Initial Parameters    
    M = 2; % Number of objectives
    fitness = [1e6, 1e6]; % Default infeasible output

    Diameter = x(1);
    Pitch = x(2);
    Nblades = floor(x(3));
    RPM_op = 3000;

    %% Check Parallel Pool (Limited to 5 Cores)
    poolobj = gcp('nocreate'); 
    if isempty(poolobj)
        parpool(5); % Start parallel pool if not already running
    end

    %% Checking Tip Speed Conformity
    R = (Diameter / 39.37) / 2; % Convert to meters
    omega = RPM_op * 2 * pi / 60; % Angular velocity (rad/s)
    TipSpeed = omega * R; % Tip speed (m/s)
    MaxTipSpeed = 340; % Maximum allowable tip speed (m/s)

    if TipSpeed > 0.9 * MaxTipSpeed
        % Constraint violated, return infeasible solution
        fprintf('Tip speed exceeds Mach threshold! Mach: %.2f\n', TipSpeed / MaxTipSpeed);
        return;
    end

    %% Running QPROP
    try
        prop_wrV1(x); % Generate Propeller Archive
        
        % Run Static QPROP (Hover)
        Result1 = stat_qprop;
        hover_thrust = 4 * Result1.Thrust;
        thrust_index = hover_thrust / (MTOW * 9.787);

        % Check Thrust Constraint
        if thrust_index < 1.4
            return;
        end

        % Run Dynamic QPROP (Cruise)
        Result2 = dyn_qprop;
        [fspeed, Vs] = power_thrust(Result2);

        % Determine valid flight speed
        if isempty(fspeed)
            fspeed_true = NaN;
        elseif isscalar(fspeed) && fspeed > Vs
            fspeed_true = 0.8*fspeed;
        else
            valid_speeds = fspeed(fspeed > Vs);
            if ~isempty(valid_speeds)
                fspeed_true = 0.8 * min(valid_speeds); % Apply safety factor
            else
                return; % No valid flight speed found
            end
        end

        % Check Stall Speed Constraint
        if fspeed_true <= Vs
            fprintf('Flight speed is below stall! Speed: %.2f\n', fspeed_true);
            return;
        end

        %% Generate Fitness Vector
        fitness(1) = -thrust_index; % Maximizing thrust
        fitness(2) = -(fspeed_true / Vs); % Maximizing flight speed ratio

    catch ME
        warning("Error in evaluate_fitness: %s", ME.message);
    end
end
