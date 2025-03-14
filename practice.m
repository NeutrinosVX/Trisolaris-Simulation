clear; clc; close all;
G = 6.67430e-11;   
dt = 1;          % 时间步长(秒)
T = 5000;        % 总时间
steps = T/dt;    % 总步数

% 单位 [(kg), (m), (m/s)]
bodies = [
    1e15,  0,  0, 0,  0,  -5, -5;    % 天体1（中心天体）
    8.5e14,  1500, 1000, 0,  -5,0, 0; % 天体2
    9.3e14, -1000, 500, 0,  -10, 0, 0 % 天体3
];

num_bodies = size(bodies, 1);

pos_history = zeros(num_bodies, 3, steps); 
vel_history = zeros(num_bodies, 3, steps); 

% 物理模拟部分保持不变
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

%% 三维网格可视化修改部分
figure('Color', 'k', 'Position', [100 100 1200 800])
hold on;

% 创建三维网格系统
grid on;
axis equal vis3d; % 保持三维等比例
set(gca, 'Color', 'k', 'GridColor', [0.4 0.4 0.4], 'GridAlpha', 0.3,...
    'XColor', 'w', 'YColor', 'w', 'ZColor', 'w', 'FontSize', 12);

% 设置坐标轴标签
xlabel('X (m)', 'FontSize', 14, 'Color', 'w');
ylabel('Y (m)', 'FontSize', 14, 'Color', 'w');
zlabel('Z (m)', 'FontSize', 14, 'Color', 'w');
title('三体运动 - 三维网格可视化', 'FontSize', 16, 'Color', 'w');

% 添加参考网格平面
[xg, yg] = meshgrid(linspace(-8000,8000,20), linspace(-8000,8000,20));
zg = zeros(size(xg));
surf(xg, yg, zg, 'FaceAlpha',0.1, 'EdgeColor',[0.5 0.5 0.5], 'LineWidth',0.5);
surf(zg, xg, yg, 'FaceAlpha',0.1, 'EdgeColor',[0.5 0.5 0.5], 'LineWidth',0.5);
surf(yg, zg, xg, 'FaceAlpha',0.1, 'EdgeColor',[0.5 0.5 0.5], 'LineWidth',0.5);

% 设置动态视角
view(45, 30); % 设置初始视角
camproj perspective; % 使用透视投影
camlight('headlight'); % 添加光源
lighting gouraud;
material shiny;

% 天体颜色和轨迹设置
colors = {'r', 'g', 'b'};
trail_length = 100;
planet_size = 12;

% 初始化天体对象
planets = gobjects(1, num_bodies);
trails = gobjects(1, num_bodies);

for i = 1:num_bodies
    % 创建轨迹线
    trails(i) = animatedline('Color', [colors{i} 0.4], 'LineWidth', 1.5);
    
    % 创建天体标记
    planets(i) = scatter3(0,0,0, planet_size*2, colors{i}, 'filled',...
        'MarkerEdgeColor','w', 'MarkerFaceAlpha',0.8);
end

% 动态可视化
for step = 1:steps
    for i = 1:num_bodies
        % 获取当前位置
        pos = pos_history(i, :, step);
        
        % 更新轨迹
        addpoints(trails(i), pos(1), pos(2), pos(3));
        
        % 更新天体位置
        set(planets(i), 'XData', pos(1), 'YData', pos(2), 'ZData', pos(3));
    end
    
    % 自动调整视角跟踪运动
    if mod(step, 100) == 0
        camorbit(0.5, 0.5); % 每100步稍微旋转视角
    end
    
    % 动态更新坐标轴范围
    current_pos = pos_history(:,:,step);
    axis_range = 1.2 * max(abs(current_pos(:)));
    axis([-axis_range axis_range -axis_range axis_range -axis_range axis_range]);
    
    drawnow limitrate;
    pause(0.001);
end
