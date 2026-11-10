%% margenes_T.m - márgenes de estabilidad frente a la temperatura
run('init_HEMS.m');
s  = tf('s');
cases = {'R',0,0; 'RM',-1.1e-3,0; 'RMK',-1.1e-3,-1.1e-3; 'K',0,-1.1e-3};
Tl = [25 60 100 140 180 220 240];
rows = {};

for c = 1:size(cases,1)
    for Tx = Tl
        R   = R_coil*(1 + alpha_cu*(Tx - T_ref_R));
        a2c = a2*(1 + cases{c,2}*(Tx - T_ref_mag));   % rigidez negativa (parte del imán)
        bc  = b *(1 + cases{c,3}*(Tx - T_ref_mag));   % ganancia fuerza/corriente
        Gc  = (1/L_coil)/(s + R/L_coil);
        Tc  = feedback((Kp_cur + Ki_cur/s)*Gc, 1);     % controlador de corriente SIN rediseñar
        Cp  = Kp_pos + Ki_pos/s + Kd_pos*N_pos*s/(s + N_pos);
        Lp  = Cp*Tc*tf(bc, [1 0 -a2c]);
        mg  = allmargin(Lp);
        ok  = max(real(pole(feedback(Lp,1)))) < 0;
        rows(end+1,:) = {cases{c,1}, Tx, first(mg.PhaseMargin), first(mg.GainMargin), ...
            1e3*first(mg.DelayMargin), ok};   %#ok<SAGROW>
    end
end

M = cell2table(rows, 'VariableNames', {'caso','T','PM_deg','GM_inf','DM_ms','estable'});
disp(M);  writetable(M, 'margenes_T.csv');

function v = first(x)
if isempty(x), v = NaN; else, v = x(1); end
end