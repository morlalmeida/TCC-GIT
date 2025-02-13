function [fitness,pitch] = evaluate_fitness(x)
    %% Load Global Parameters
    global Vs MTOW;

    %% Setting Initial Parameters    
    M = 2; % Number of objectives
    fitness = [1e6, 1e6]; % Default infeasible output

    Diameter = x(1);
    % Pitch = x(2);
    Nblades = round(x(2));
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
        [pitch] = prop_wrV3(x); % Generate Propeller Archive
        % pitch = check_pitch;
        
        % Run Static QPROP (Hover)
        Result1 = stat_qprop;
        RPM = Result1.RPMs;
        Power_Elec = 4.*Result1.Pelectric;
        hover_thrust = 4.*Result1.Thrust;
        target_Power = 496; %kW, Peak EMRAX 228
        
        % Checking Static Constraints
        RPM_closest = interp1(Power_Elec, RPM, target_Power);

        % If the interpolated RPM is below 3000, find TWR at 3000 RPM
        if RPM_closest <= 3000
            TWR_3000 = interp1(RPM, hover_thrust, 3000); % Interpolating TWR at 3000 RPM
        elseif isnan(RPM_closest) || RPM_closest >= 3000
            return
        end

        thrust_index = TWR_3000 / (MTOW * 9.787);

        if thrust_index < 1.4
            return
        end

        % Run Dynamic QPROP (Cruise)
        Result2 = dyn_qprop;
        [fspeed, Vs] = power_thrust(Result2);

        % Determine valid flight speed
        if isempty(fspeed)
            fspeed_true = NaN;
            return
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
