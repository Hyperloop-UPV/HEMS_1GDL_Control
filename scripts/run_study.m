clear; clc; close all;

% Añadir automáticamente las subcarpetas del proyecto (incluyendo src/modelos) al Path
script_folder = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(script_folder, '..')));

init_HEMS;                           % Carga parámetros e inicializa el workspace
model = 'HEMS_1GDL_temperatura';     % Define 'model' tras la inicialización
load_system(model);

%% 1) Definición de escenarios
add = @(g,T,bB,bk,F,on,ka,ts) struct('grp',g,'T_init',T,'beta_Br',bB,'beta_ki',bk, ...
    'F_load',F,'thermal_on',on,'k_acc',ka,'t_sim',ts);

sc = add('R',25,0,0,0,0,1,8);  sc(1) = [];   % lista vacía con los campos correctos

Tvec = [25 40 60 80 100 120 140 180 220];
for Tx = Tvec
    sc(end+1) = add('R',   Tx,  0,      0,      0,0,1,8);   %#ok<SAGROW>  solo R(T)
    sc(end+1) = add('RM',  Tx, -1.1e-3, 0,      0,0,1,8);   % R(T) + imanes
    sc(end+1) = add('RMK', Tx, -1.1e-3,-1.1e-3, 0,0,1,8);   % R(T) + imanes + bobina
    sc(end+1) = add('K',   Tx,  0,     -1.1e-3, 0,0,1,8);   % peor caso: solo cae la bobina
end

Fl = [0 50 100 150 200 250 300];                         % carga extra a 25 ºC
for Fx = Fl
    sc(end+1) = add('carga', 25, 0, 0, Fx, 0, 1, 11);
end

sc(end+1) = add('dinamico_RM',    25, -1.1e-3, 0, 0,   1, 50, 8);   % calentamiento acoplado
sc(end+1) = add('dinamico_carga', 25,  0,      0, 150, 1,  5, 11);

%% 2) Preparar y ejecutar
n = numel(sc);
in(1:n) = Simulink.SimulationInput(model);
for k = 1:n
    in(k) = in(k).setVariable('T_init',     sc(k).T_init);
    in(k) = in(k).setVariable('beta_Br',    sc(k).beta_Br);
    in(k) = in(k).setVariable('beta_ki',    sc(k).beta_ki);
    in(k) = in(k).setVariable('F_load',     sc(k).F_load);
    in(k) = in(k).setVariable('thermal_on', sc(k).thermal_on);
    in(k) = in(k).setVariable('k_acc',      sc(k).k_acc);
    in(k) = in(k).setModelParameter('StopTime', num2str(sc(k).t_sim));
end

out = sim(in, 'ShowProgress', 'on');

%% 3) Métricas
p = struct('t_step',t_step,'t_load',t_load,'z0',z0,'z_final',0.018, ...
    'gap_min',min(airgap_bp),'gap_max',max(airgap_bp),'V_max',V_max,'I_max',I_max);

for k = 1:n
    if ~isempty(out(k).ErrorMessage), warning('Escenario %d falló: %s', k, out(k).ErrorMessage); end
    row = sc(k);  M = calc_metrics(out(k), p);
    for f = fieldnames(M)', row.(f{1}) = M.(f{1}); end
    res(k) = row;                                            %#ok<SAGROW>
end

Rt = struct2table(res);
disp(Rt(:, {'grp','T_init','F_load','OS_pct','ts_s','I_pre_A','I_ss_A','V_ss_V','V_max_V','I_max_A','z_err_mm','unstable'}))
writetable(Rt, 'estudio_termico_metricas.csv');
save('estudio_termico.mat', 'sc', 'res', 'out', 'p', '-v7.3');

%% ---------- funciones locales ----------
function M = calc_metrics(o, p)
zt = o.get('z_log');  t = (0:1e-3:zt.Time(end))';   % eje uniforme de 1 ms
ia = @(x) find([true; diff(x(:)) > 0]);   % quita los tiempos repetidos que genera Simulink
rs = @(ts) interp1(ts.Time(ia(ts.Time)), ts.Data(ia(ts.Time)), t, 'linear', 'extrap');

z = rs(zt);  I = rs(o.get('I_log'));  V = rs(o.get('V_log'));  Tc = rs(o.get('T_log'));  P = rs(o.get('P_log'));

st   = p.z_final - p.z0;                         % amplitud del escalón
post = t >= p.t_step;
pre  = t >= p.t_step-0.5 & t < p.t_step;         % justo antes del escalón
ss   = t >= p.t_load-1   & t < p.t_load;         % régimen estacionario (antes de la carga)
aft  = t >= p.t_load;                            % después de la carga

M.OS_pct = max(0, (max(z(post & t < p.t_load)) - p.z_final)/st*100);
idx = find(abs(z - p.z_final) > 0.02*st & post & t < p.t_load, 1, 'last');
if isempty(idx), M.ts_s = 0; else, M.ts_s = t(idx) - p.t_step; end   % ts al 2 %

M.I_pre_A  = mean(I(pre));                       % corriente de sostén a z0
M.I_ss_A   = mean(I(ss));                        % corriente de sostén a 18 mm
M.V_ss_V   = mean(V(ss));
M.V_max_V  = max(abs(V(post)));
M.I_max_A  = max(I(post));
M.I_min_A  = min(I(post & t < p.t_load));
M.z_err_mm = (mean(z(ss)) - p.z_final)*1e3;
M.z_pico_after_mm = max(z(aft))*1e3;             % pico tras la carga
M.I_pico_after_A  = max(I(aft));
M.I_final_A = mean(I(t >= t(end)-1));
M.T_final_C = Tc(end);
M.P_final_W = P(end);
M.sat_V = any(abs(V) >= 0.99*p.V_max);
M.sat_I = any(I >= 0.99*p.I_max);
M.unstable = any(isnan(z)) || any(z > p.gap_max) || any(z < p.gap_min);   % sale del rango de la tabla
end