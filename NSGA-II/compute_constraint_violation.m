function violations = compute_constraint_violation(x)
    % Load aircraft parameters (stall speed & MTOW)
    global Vs

    % Define constraint thresholds
    min_speed = Vs + 2;  % Minimum required flight speed
    min_hover_thrust = 1.4; % Minimum hover thrust


    % Number of solutions to evaluate
    num_solutions = size(x, 1);

    % Initialize violations vector
    violations = zeros(num_solutions, 1);

    % Loop through each solution
    for i = 1:num_solutions
        % Extract design variables (Diameter, Pitch, Number of Blades)
        design = x(i, :);

        % Evaluate the propeller performance for the given design
        [flight_speed, hover_thrust] = evaluate_design(design);

        % Compute violation penalties
        speed_violation = max(0, min_speed - flight_speed);
        thrust_violation = max(0, min_hover_thrust - hover_thrust);

        % Sum of constraint violations
        violations(i) = speed_violation + thrust_violation;
    end
end
