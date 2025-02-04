function [fspeed_true, thrust_index] = evaluate_design(x)
    % Load aircraft parameters
    global Vs MTOW
    
    % Initialize outputs
    fspeed_true = NaN;
    thrust_index = NaN;

try
        prop_wrV1(x); % Generate Propeller Archive
        
        % Run Static QPROP (Hover)
        Result1 = stat_qprop;
        hover_thrust = 4 * Result1.Thrust;
        thrust_index = hover_thrust / (MTOW * 9.787);
        
        % Run Dynamic QPROP (Cruise)
        Result2 = dyn_qprop;
        [fspeed, Vs] = power_thrust(Result2);
  
        % 🔹 Select Valid Flight Speed
        if isempty(fspeed)  % Handle unexpected empty results
            fspeed_true = NaN;
        elseif isscalar(fspeed) && fspeed > Vs
            fspeed_true = 0.8*fspeed;
        else
            valid_speeds = fspeed(fspeed > Vs); % Filter out speeds below stall
            if ~isempty(valid_speeds)
                fspeed_true = 0.8 * min(valid_speeds); % Select the lowest valid speed with safety factor
            end
        end
    catch ME
        warning("Error in evaluate_design: %s", ME.message);
        fspeed_true = NaN;
        thrust_index = NaN;
    end
end





% function [fspeed_true,thrust_index] = evaluate_design(x)
% %% Running QPROP, Thrust and Flight Speed
%     try
%         prop_wrV1(x)                            % Generating Propller Archive
%         [Result1] = stat_qprop;                 % Running Static QPROP - Hover
%         hover_thrust = 4*Result1.Thrust;
%         thrust_index = hover_thrust/(870*9.787);
%                  
%         [Result2] = dyn_qprop;                  % Running Dynamic QPROP - Cruise
%         [fspeed,Vs] = power_thrust(Result2);    % Obtaining Flight Speed
% 
%  %% Flight Speed Determination
%         i = 1;
%         if isscalar(fspeed)                     % Obtaining reliable Flight Speed
%             if fspeed > Vs
%                 fspeed_true = fspeed;
%             end
%         elseif length(fspeed) > 1
%             for i = 1:length(fspeed)
%                 if fspeed(i) <= Vs
%                     continue
%                 elseif fspeed(i) > Vs
%                     fspeed_true = 0.8*fspeed(i);
%                     break
%                 end
%             end
%         end
%     catch
%   end
