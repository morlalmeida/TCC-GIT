%% REQUIRED AND AVAILABLE POWER/THRUST FUNCITION
% Luca Morla de Almeida
% May 2024

function [fspeed,Vs] = power_thrust(Result2)
%% ============================ INPUTS ====================================
Sw   = 12.25;   % Wing Area [m^2]
MTOW = 870;    % Take-Off Weight [kg]
g    = 9.81;   % Gravity [m/s^2]
rho  = 1.225;  % Air Density [kg/m^3]
plot = 0;      % Boolean for plotting graphs
fspeed = [];
% load('68x345prop.mat')% Comentar se for usar como FUNCTION do QPROP;
% Tenha certeza que as dimensões do Result sejam as mesmas das velocidades.

%% ========================== LIFT & DRAG =================================

v = linspace(5,56,200);  % Velocities to be analyzed
n1 = size(v);
n1 = n1(1,2);

% Lift Coefficient calculations
CL = zeros(1,n1);
for i = 1:n1
    CL(1,i) = 2*MTOW*g/(rho*Sw*v(1,i)^2);
end

Vs = sqrt((2*MTOW*g)/(rho*Sw*1.389));

% Drag Polar input

CD = zeros(1,n1);
for i = 1:n1
    CD(1,i) = 0.0018 - (0.0091*CL(1,i)) + (0.094*(CL(1,i)^2));
end

%% ===================== REQUIRED POWER/THRUST ============================

pr = zeros(1,n1);
for i = 1:n1
    pr(1,i) = (MTOW*g*v(1,i)*CD(1,i)/CL(1,i))/1000; % Required Power (kW)
end

for i = 1:n1
    reqt(1,i) = ((pr(1,i)/v(1,i))/g)*1000;          % Required Thrust (N)
end

%% ===================== AVAILABLE POWER/THRUST ===========================

Pelectric = 4*Result2.Pelectric;
Thrust    = 4*Result2.Thrust/g;

Pelectric2 = (4*Result2.Thrust).*v/1000;
D = 0.5.*v.^2*Sw.*rho.*CD;
ReqPow = D.*v/1000;
error = 1;
j = 1;

for i = 1:n1
    real = abs(Pelectric2(i) - ReqPow(i));
    if real <= error
        fspeed(j) = (v(i-1) + v(i+1))/2;
        j = j+1;
    end
end

if isempty(fspeed) || fspeed(j-1) <= Vs
    error = 40;
    for i = 1:n1
        real = abs(Pelectric2(i) - ReqPow(i));
        if real <= error
            fspeed(j) = (v(i-1) + v(i+1))/2;
            j = j+1;
        end
    end
    fspeed = sort(fspeed);
end


%% ============================ PLOTTING ==================================
if plot == 1
figure(1) 
% plot (v,Pelectric,'-b','LineWidth',1.5)
% hold on
% plot (v, pr,'-r','LineWidth',1.5)
% hold on
plot (v, Pelectric2,'-b','LineWidth',1.5)
hold on
plot (v, ReqPow,'-r','LineWidth',1.5)
grid on
grid minor
legend('Available Power','Required Power','Location','best')
title('Required x Available Power') 
xlabel('Velocity [m/s]')
ylabel('Power [kW]') 
set (gca,'Ytick',0:100:1000)
axis ([0 55 0 400])
xline(Vs,'--k','Linewidth',1.2,'Label','Stall')

figure(2) 
plot (v,Thrust,'-b','LineWidth',1.5)
hold on
plot (v, reqt,'-r','LineWidth',1.5)
grid on
grid minor
legend('Available Thrust','Required Thrust','Location','best')
title('Required x Available Thrust') 
xlabel('Velocity [m/s]')
ylabel('Thrust [kgf]') 
set (gca, "Ytick" , 0:250:1500)
axis ([0 55 0 800])
xline(Vs,'--k','Linewidth',1.2,'Label','Stall')

figure(3)
plot (v,pr,'-c','LineWidth',1.7)
grid on
grid minor
set(gcf, 'InvertHardCopy', 'off'); 
set(gcf,'Color',[0 0 0]); % RGB values [0 0 0] indicates black color
set(gca,'Color','k');
title('Required Power','Color','w')
xlabel('Velocity [m/s]')
ylabel('Power [kW]')
xlim([5 50])
set(gca,'XColor',[1 1 1]); % Set RGB value ([1 1 1] = white)
set(gca,'YColor',[1 1 1]); % Set RGB value ([1 1 1] = white)
% xline(22.23,'--w','Linewidth',1,'Label','Stall')

figure(4)
plot (v,reqt,'-c','LineWidth',1.7)
grid on
grid minor
set(gcf, 'InvertHardCopy', 'off'); 
set(gcf,'Color',[0 0 0]); % RGB values [0 0 0] indicates black color
set(gca,'Color','k');
title('Required Thrust','Color','w')
xlabel('Velocity [m/s]')
ylabel('Thurst [kgf]')
set(gca,'XColor',[1 1 1]); % Set RGB value to what you want
set(gca,'YColor',[1 1 1]); % Set RGB value to what you want
xlim([5 55])
% xline(22.23,'--w','Linewidth',1,'Label','Stall')

figure(5)
subplot(1,2,1), plot (v,pr,'-b','LineWidth',1.7)
grid on
grid minor
ylabel('Power [kW]')
xlabel('Velocity [m/s]')
% xline(20,'--k','Linewidth',1,'Label','Stall')
xlim([5 55])
subplot(1,2,2), plot(v,reqt,'-r','LineWidth',1.7)
grid on
grid minor
xlabel('Velocity [m/s]')
ylabel('Thrust [kgf]')
xlim([5 55])
% xline(22.23,'--k','Linewidth',1,'Label','Stall')
end
end