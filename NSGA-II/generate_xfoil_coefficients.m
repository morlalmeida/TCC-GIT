function [CL0, CLa, CLmin, CLmax, CD0, CD2u, CD2l, CLCD0] = generate_xfoil_coefficients(D, pitch, c_root, c_tip, RPM_hover, V_flight, airfoil_name)
    % Given conditions
    altitude = 1000; % meters (ISA conditions)
    rho = 1.112; % kg/m^3 (air density at 1000m)
    mu = 1.74e-5; % Pa·s (dynamic viscosity at 1000m)
    
    R = D / 2; % Propeller radius in meters
    num_sections = 20; % Number of radial sections
    
    % Define blade sections
    radii = linspace(0.2 * R, R, num_sections); % Avoid hub effects by starting at 20% span
    chords = linspace(c_root, c_tip, num_sections); % Linear chord distribution
    
    % Estimated rotational speeds
    RPM_cruise = (V_flight / pitch) * 60; % Approximate RPM in cruise
    omega_hover = (RPM_hover * 2 * pi) / 60; % rad/s
    omega_cruise = (RPM_cruise * 2 * pi) / 60; % rad/s
    
    % Compute local velocities
    V_rot_hover = omega_hover * radii; % Rotational component in hover
    V_rot_cruise = omega_cruise * radii; % Rotational component in cruise
    
    % Effective velocities
    V_eff_hover = V_rot_hover; % Hover: only rotational speed
    V_eff_cruise = sqrt(V_rot_cruise.^2 + V_flight^2); % Cruise: combined velocity
    
    % Compute Reynolds number for each section
    Re_hover = (rho .* V_eff_hover .* chords) ./ mu;
    Re_cruise = (rho .* V_eff_cruise .* chords) ./ mu;
    
    % Compute weighted spanwise average Reynolds numbers
    Re_weighted_hover = trapz(radii, Re_hover .* chords .* radii) / trapz(radii, chords .* radii);
    Re_weighted_cruise = trapz(radii, Re_cruise .* chords .* radii) / trapz(radii, chords .* radii);
    
    % Generate XFOIL input file
    filename = sprintf('xfoil_input_%s.txt', airfoil_name);
    polar_filename = sprintf('%s_polar.dat', airfoil_name);
    fileID = fopen(filename, 'w');
    
    fprintf(fileID, 'LOAD %s.dat\n', airfoil_name);
    fprintf(fileID, 'OPER\n');
    fprintf(fileID, 'VISC %f\n', Re_weighted_hover);
    fprintf(fileID, 'ITER 200\n');
    fprintf(fileID, 'PACC\n');
    fprintf(fileID, '%s\n\n', polar_filename);
    fprintf(fileID, 'ASEQ -5 15 0.5\n'); % Angle of attack sequence from -5 to 15 degrees in 0.5-degree increments
    fprintf(fileID, 'QUIT\n');
    
    fclose(fileID);
    
    % Run XFOIL automatically
    system(sprintf('xfoil.exe < %s', filename));
    
    % Read XFOIL output coefficients
    data = readmatrix(polar_filename, 'NumHeaderLines', 12);
    
    if isempty(data)
        error('XFOIL did not generate valid output. Check airfoil data.');
    end
    
    alpha = data(:, 1); % Angle of attack
    CL = data(:, 2);    % Lift coefficient
    CD = data(:, 3);    % Drag coefficient
    
    % Calculate CL0 (Lift coefficient at zero angle of attack)
    CL0 = interp1(alpha, CL, 0, 'linear');
    
    % Calculate CLa (Lift curve slope, dCL/dα)
    dCL_dalpha = diff(CL) ./ diff(alpha);
    CLa = mean(dCL_dalpha); % Average slope
    
    % Calculate CLmin and CLmax
    CLmin = min(CL);
    CLmax = max(CL);
    
    % Calculate CD0 (Drag coefficient at zero lift)
    CD0 = interp1(CL, CD, 0, 'linear');
    
    % Fit a quadratic curve to the drag polar (CD vs. CL) to find CD2u and CD2l
    % Upper branch (positive CL)
    pos_indices = CL > 0;
    p_upper = polyfit(CL(pos_indices), CD(pos_indices), 2);
    CD2u = p_upper(1);
    
    % Lower branch (negative CL)
    neg_indices = CL < 0;
    p_lower = polyfit(CL(neg_indices), CD(neg_indices), 2);
    CD2l = p_lower(1);
    
    % Calculate CL/CD0 (Lift-to-drag ratio at zero angle of attack)
    CD_at_CL0 = interp1(CL, CD, CL0, 'linear');
    CLCD0 = CL0 / CD_at_CL0;
end

% Example usage
[CL0, CLa, CLmin, CLmax, CD0, CD2u, CD2l, CLCD0] = generate_xfoil_coefficients(1.727, 0.965, 0.9, 0.05, 3000, 36, 'NACA2412');