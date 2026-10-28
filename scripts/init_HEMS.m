%% =========================================================
% HEMS - BANCADA DE LEVITACIÓN 1 GDL V2  (HYPERLOOP UPV)

clearvars; clc;

%% Planta
g0 = 9.81;  m = 62.5;
R_coil = 1.28;  L_coil = 32e-3;
V_max = 400;  I_max = 55;
z0 = 16.36e-3;  airgap_zero_current = z0;
I_initial = 0;  v_initial = 0;  z_initial = z0;

%% LUT (filas = corriente, columnas = airgap)
current_bp = -60:5:60;
airgap_bp  = (10:0.5:23)*1e-3;
[GAP,CURR] = meshgrid(airgap_bp,current_bp);
Fz_table = (m*g0)*(z0./GAP).^2 + 15*CURR;     % sintética

%% Linealización desde la LUT
F  = @(I,z) interp2(airgap_bp,current_bp,Fz_table,z,I,'linear');
Ks = -(F(0,z0+0.5e-3)-F(0,z0-0.5e-3))/(2*0.5e-3);
ki =  (F(5,z0)-F(-5,z0))/(2*5);
a2 = Ks/m;  b = ki/m;

%% Lazo de corriente
wc_cur = 470;
Kp_cur = L_coil*wc_cur;   Ki_cur = R_coil*wc_cur;   Kd_cur = 0;
Ts_cur = 0.5e-3;

%% Lazo de posición
wn = 19.5;  zeta = 0.82;
Kp_pos = (wn^2 + a2)/b;
Kd_pos = 2*zeta*wn/b;
Ki_pos = Kp_pos/2;
N_pos  = 100;  Ts_pos = 1e-3;
assert(Kp_pos > Ks/ki, 'Kp demasiado bajo');

%% Sensor de posición: SICK OD2000-1301T15
d_off   = 100e-3;        % [m] distancia sensor-imán con airgap = 0 (confirmar con Miquel)
d_min   = 60e-3;         % [m] inicio del rango
d_max   = 200e-3;        % [m] fin del rango
q_sens  = 4e-6;          % [m] resolución
Ts_sens = 1/7500;        % [s] muestreo
assert(d_off + min(airgap_bp) >= d_min && d_off + max(airgap_bp) <= d_max, ...
    'El airgap queda fuera del rango del sensor');


%% Feedforward (se usa en la FASE E)
I_ff = zeros(size(airgap_bp));
for k = 1:numel(airgap_bp)
    I_ff(k) = interp1(Fz_table(:,k), current_bp, m*g0, 'linear','extrap');
end

t_sim = 5;
fprintf('Ks=%.0f  ki=%.1f  Kp_cur=%.2f Ki_cur=%.1f | Kp_pos=%.0f Ki_pos=%.0f Kd_pos=%.1f\n',...
    Ks,ki,Kp_cur,Ki_cur,Kp_pos,Ki_pos,Kd_pos);
%% Definir la planta matemática linealizada
Kb = 15 / 62.5;
w02 = 75000 / 62.5;
G_pos = tf(Kb, [1, 0, -w02]);



%% lazo de corriente
s = tf('s');
Gcur = (1/L_coil)/(s + R_coil/L_coil);
Tcur = feedback((Kp_cur + Ki_cur/s)*Gcur, 1);
stepinfo(Tcur)

%% lazo de posición
Cpos = Kp_pos + Ki_pos/s + Kd_pos*N_pos*s/(s+N_pos);
Lpos = Cpos*Tcur*tf(b,[1 0 -a2]);
Tpos = feedback(Lpos,1);
max(real(pole(Tpos)))     % debe ser < 0
allmargin(Lpos)           % el margen de ganancia inferior sale ≈ 1.3

