function x_repaired = repair_function(x)
    global Vs 
    
    min_speed = Vs + 2; % Ensure speed is above stall margin
    min_hover_thrust = 1.4; % Ensure hover thrust is sufficient

    % Evaluate current design performance
    [fspeed_true, thrust_index] = evaluate_design(x);

    % -------------------------------
    % Adjust Pitch if Speed is Too Low
    % -------------------------------
    if fspeed_true < min_speed
        x(2) = x(2) * 1.1; % Increase pitch by 10%
    end

    % -------------------------------
    % Adjust Diameter or Blades if Hover Thrust is Too Low
    % -------------------------------
    if thrust_index < min_hover_thrust
        if x(3) < 5 % Increase number of blades if not too high
            x(3) = x(3) + 1;
        else
            x(1) = x(1) * 1.05; % Otherwise, increase diameter by 5%
        end
    end

    % -------------------------------
    % Ensure Number of Blades is an Integer
    % -------------------------------
    x(3) = round(x(3)); % Rounds number of blades to nearest integer

    % Return repaired solution
    x_repaired = x;
end
