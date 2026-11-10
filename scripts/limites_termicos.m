%% limites_termicos.m - cuánto tarda en alcanzar el límite y cuánta corriente cuesta sostener
run('init_HEMS.m');
T0 = 25;                                                   % temperatura de partida [ºC]

% (a) Tiempo hasta el límite a corriente constante, sin refrigeración
Ia   = linspace(5, 55, 200);
a    = R_coil*Ia.^2/C_th;                                  % K/s al empezar
lim  = @(Tl) log((1 + alpha_cu*(Tl - T_ref_R))/(1 + alpha_cu*(T0 - T_ref_R)))./(alpha_cu*a);

fig  = figure('Units','centimeters','Position',[2 2 14 8]);
semilogy(Ia, lim(T_lim_mag), Ia, lim(T_lim_coil)); grid on
xlabel('Corriente constante [A]'); ylabel('Tiempo hasta el límite [s]')
legend(sprintf('Imanes (%d °C)',T_lim_mag), sprintf('Cobre (%d °C)',T_lim_coil))
exportgraphics(fig, 'fig_tiempo_limite.png', 'Resolution', 300);

% (b) Corriente de sostén y tensión frente a la temperatura (pérdida del imán)
Th     = 25:5:260;
beta   = -1.1e-3;
I_hold = -beta*(Th - T_ref_mag)*m*g0/ki;                   % A para sostener a z0
I_ss   = 7.1 + (z0/0.018)^2*I_hold;                        % A a 18 mm
V_ss   = R_coil*(1 + alpha_cu*(Th - T_ref_R)).*I_ss;       % V en régimen

fig = figure('Units','centimeters','Position',[2 2 16 7]);
tiledlayout(1,2,'TileSpacing','compact','Padding','compact');
nexttile; plot(Th, I_hold); xline(T_lim_mag,'--r'); xline(T_lim_coil,'--k')
xlabel('Temperatura [°C]'); ylabel('Corriente de sostén a 16.36 mm [A]')
nexttile; plot(Th, V_ss);   xline(T_lim_mag,'--r'); xline(T_lim_coil,'--k')
xlabel('Temperatura [°C]'); ylabel('Tensión en régimen a 18 mm [V]')
exportgraphics(fig, 'fig_sosten_vs_T.png', 'Resolution', 300);