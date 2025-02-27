function prop_wrV2(x)

%% Setting Base Propeller
D = 57; % Propeller diameter [in]
length1  = D/39.37; % Propeller diameter [m]
r_length = length1/2;
r_base = [0.1448	0.181	0.2172	0.2534	0.2896	0.3258	0.3619	0.3981	0.4343	0.4705	0.5067	0.5429	0.5791	0.6153	0.6515	0.6877	0.7058	0.7167];
chord_base = [0.1186	0.1579	0.1765	0.1767	0.1647	0.1525	0.1408	0.1297	0.1193	0.1092	0.0995	0.0896	0.0795	0.0684	0.0557	0.0393	0.0278	0.0176];
beta_base = [44.3	38.0	33.2	29.5	26.5	24.1	22.1	20.5	19.0	17.8	16.7	15.8	15.0	14.2	13.6	13.0	12.7	12.6];

i = 1;
for i = 1:18
    section(i) = r_base(i)/r_length;
    i = i+1;
end

croot_relation = chord_base(1)/length1;
croot = croot_relation*(x(1)/39.37);
cmid1 = x(4)*croot;
cmid2 = x(5)*croot;
ctip = x(6)*croot;

% Bézier Interpolation using De Casteljau Algorithm
P0 = croot;   % Root chord
P1 = cmid1;   % Control point at 33% span
P2 = cmid2;   % Control point at 66% span
P3 = ctip;    % Tip chord

k = 1;
for k = 1:length(section)
    % Quadratic Bézier Curve
    chord_bezier(k) = (1 - section(k)).^3 * P0 + 3*(1 - section(k)).^2 .*...
        section(k) * P1 + 3*(1 - section(k)) .* section(k).^2 * P2 +...
        section(k).^3 * P3;
end
% c_fit = polyfit(section,chord_base,4);


% inputs variables:
% x(1) - Blade radius
% x(2) to x(5) - coefficients of beta distribution
% x(6) to x(9) - coefficients of chord distribuition
% x(10) - perfil

D_otm = x(1);
pitch = x(2);
r_otm_in = D_otm/2;
length_otm = D_otm/39.37;
rlength_otm = length_otm/2;

j = 1;
for j = 1:length(section)
    r_otm(j) = section(j)*rlength_otm;
    % chord_otm(j) = c_fit(1)*section(j)^4 + c_fit(2)*section(j)^3 + ...
    %     c_fit(3)*section(j)^2 + c_fit(4)*section(j) + c_fit(5);
    beta_otm(j) = atand(pitch/(pi*D_otm*section(j)));
    j = j+1;
end
 
beta75_otm = beta_otm(12);
check_pitch = tand(beta75_otm)*pi*D_otm*0.75;

N_blade = round(x(3));
Re_exp  = -0.2;

% Get discretized points of beta and chord from the splines
beta    = beta_otm';
chord   = chord_bezier';
r       = r_otm';

%% Write propeller file
propeller = fopen('prop.txt','wt');                                         % Create prop.txt file

length1  = D_otm;                                                           % Diameter given in inches
angle   = pi*0.75*D_otm*tand(beta(12));                                     % Pitch angle
fprintf(propeller, 'TCC %.0fx%.0f \n\n', length1,angle);                    % Propeller identification name
fprintf(propeller, '%2.0f  %.2f ! Nblades R \n\n', N_blade, D_otm/2);       % Number of blades and reference radius of the blade
fac = ones(1,3);
add = zeros(1,3);
josh = [0.0000  6.2832];
joshin = [-0.8000  1.2000];
joshao = [0.01000  0.00800  0.00600  0.4000];
joshen = [150000.0  -0.500];
A = [r chord beta]';

fprintf(propeller, '%5.2f %6.2f     ! Clo Cla \n',josh);
fprintf(propeller, '%5.1f %6.2f     ! Clmin Clmax \n\n',joshin);

fprintf(propeller, ' %5.4f %6.3f %6.3f  %6.3f     ! Cdo Cd2u Cd2l ClCdo\n',joshao);
fprintf(propeller, ' %6.0f %6.2f                    ! REref REexp \n\n',joshen);

fprintf(propeller, '%5.2f %6.2f %6.2f     ! Rfac Cfac Bfac\n',fac);
fprintf(propeller, '%5.2f %6.2f %6.2f     ! Radd Cadd Badd\n\n',add);

fprintf(propeller, '# r    chord   beta\n');
fprintf(propeller, '%5.2f %6.2f %6.1f\n', A);

fclose(propeller);