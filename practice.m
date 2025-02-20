
clear; clc; close all;
G = 6.67430e-11;   
dt = 10;          % step(seconds)
T = 100000;             % total time
steps = T/dt;       % total steps

% Units [(kg), (m), (m/s)]
%  Every row[m, x, y, z, vx, vy, vz]
bodies = [
    9.7e11,  0,  0, 0,  0,  0, 0;    
    8e11, 1000, 0, 0,  0, 0, 0;    
    9e11,500, 500, 0,  0, 0, 0     
];

num_bodies = size(bodies, 1);


pos_history = zeros(num_bodies, 3, steps); 
vel_history = zeros(num_bodies, 3, steps); 


for step = 1:steps
    pos_history(:, :, step) = bodies(:, 2:4);
    vel_history(:, :, step) = bodies(:, 5:7);
    forces = zeros(num_bodies, 3);
    for i = 1:num_bodies
        for j = 1:num_bodies
            if i ~= j
                r = bodies(j, 2:4) - bodies(i, 2:4);
                distance = norm(r);
                force_mag = G * bodies(i,1) * bodies(j,1) / (distance^2 + eps);
                forces(i,:) = forces(i,:) + force_mag * r/distance;
            end
        end
    end
    

    for i = 1:num_bodies
        acceleration = forces(i,:) / bodies(i,1);
        bodies(i,5:7) = bodies(i,5:7) + acceleration * dt;
        bodies(i,2:4) = bodies(i,2:4) + bodies(i,5:7) * dt;
    end
end

figure('Color', 'k', 'Position', [100 100 800 800])
hold on;
axis equal;
grid on;
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)');
title('Trisolaris');
set(gca, 'Color', 'k', 'XColor', 'w', 'YColor', 'w', 'ZColor', 'w');
colors = ['r', 'g', 'b'];
trail_length = 100; 
planets = gobjects(1, num_bodies);
for i = 1:num_bodies
    planets(i) = plot3(0,0,0, 'o',...
        'MarkerSize', 8,...
        'MarkerFaceColor', colors(i),...
        'MarkerEdgeColor', 'w');
end

% Visualization
for step = 1:steps
    for i = 1:num_bodies
        % update position
        set(planets(i),...
            'XData', pos_history(i,1,step),...
            'YData', pos_history(i,2,step),...
            'ZData', pos_history(i,3,step));
        
        % trailing
        start_trail = max(1, step-trail_length);
        plot3(squeeze(pos_history(i,1,start_trail:step)),...
            squeeze(pos_history(i,2,start_trail:step)),...
            squeeze(pos_history(i,3,start_trail:step)),...
            'Color', [colors(i) 0.3],...
            'LineWidth', 1);
    end
    drawnow;
    pause(0.0001); %speed of animation
end