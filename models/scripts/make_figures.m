%% make_figures.m - figuras del informe con un único estilo
load('estudio_termico.mat');   Rt = struct2table(res);
set_style();
col = struct('R',[0 0.447 0.741], 'RM',[0.850 0.325 0.098], 'RMK',[0.466 0.674 0.188], 'K',[0.494 0.184 0.556]);
lab = struct('R','Solo R(T)', 'RM','R(T) + imán', 'RMK','R(T) + imán + bobina', 'K','Solo pérdida de bobina');

% (a) Curvas temporales superpuestas, una por temperatura
for g = {'R','RM','RMK'}
    overlay(out, sc, g{1}, 'z_log', 1e3, 'Entrehierro [mm]', [2.5 7], [16 18.6], ['fig_z_vs_T_' g{1}]);
    overlay(out, sc, g{1}, 'I_log', 1,   'Corriente [A]',    [2.5 7], [-3 20],    ['fig_I_vs_T_' g{1}]);
    overlay(out, sc, g{1}, 'V_log', 1,   'Tensión [V]',      [2.5 7], [-10 45],   ['fig_V_vs_T_' g{1}]);
end

% (b) Métricas frente a la temperatura, las cuatro variantes en cada figura
metr = {'ts_s','Tiempo de asentamiento (2 %) [s]'; 'OS_pct','Sobreoscilación [%]'; ...
    'I_pre_A','Corriente de sostén a 16.36 mm [A]'; 'I_ss_A','Corriente de sostén a 18 mm [A]'; ...
    'V_ss_V','Tensión en régimen [V]'; 'V_max_V','Tensión máxima [V]'; ...
    'z_err_mm','Error de posición antes de la carga [mm]'};

for m = 1:size(metr,1)
    fig = figure('Units','centimeters','Position',[2 2 14 8]); hold on
    for g = {'R','RM','RMK','K'}
        s = sortrows(Rt(strcmp(Rt.grp,g{1}),:), 'T_init');
        plot(s.T_init, s.(metr{m,1}), '-o', 'Color', col.(g{1}), 'DisplayName', lab.(g{1}));
    end
    xlabel('Temperatura de la bobina [°C]'); ylabel(metr{m,2}); legend('Location','best');
    save_fig(fig, ['fig_' metr{m,1} '_vs_T']);
end

% (c) Escalón de carga a 25 °C: límite de recuperación
s = sortrows(Rt(strcmp(Rt.grp,'carga'),:), 'F_load');
fig = figure('Units','centimeters','Position',[2 2 16 7]);
tiledlayout(1,2,'TileSpacing','compact','Padding','compact');
nexttile; plot(s.F_load, s.z_pico_after_mm, '-o'); yline(p.gap_max*1e3,'--r','Límite de la tabla');
xlabel('Carga extra [N]'); ylabel('Pico de entrehierro [mm]')
nexttile; plot(s.F_load, s.I_pico_after_A, '-o'); yline(p.I_max,'--r','Corriente máxima');
xlabel('Carga extra [N]'); ylabel('Pico de corriente [A]')
save_fig(fig, 'fig_carga');

% (d) Calentamiento acoplado: T, I y z frente al tiempo
for name = {'dinamico_RM','dinamico_carga'}
    k = find(strcmp({sc.grp}, name{1}));  o = out(k);
    fig = figure('Units','centimeters','Position',[2 2 14 12]);
    tl = tiledlayout(3,1,'TileSpacing','compact','Padding','compact');
    nexttile; plot(o.get('T_log').Time, o.get('T_log').Data); ylabel('Temperatura [°C]')
    nexttile; plot(o.get('I_log').Time, o.get('I_log').Data); ylabel('Corriente [A]')
    nexttile; plot(o.get('z_log').Time, o.get('z_log').Data*1e3); ylabel('Entrehierro [mm]'); xlabel('Tiempo de simulación [s]')
    title(tl, sprintf('%s (k_{acc} = %d)', strrep(name{1},'_',' '), sc(k).k_acc))
    save_fig(fig, ['fig_' name{1}]);
end

%% ---------- funciones locales ----------
function set_style()
set(groot, 'defaultAxesFontName','Times New Roman', 'defaultAxesFontSize',10, ...
    'defaultLineLineWidth',1.5, 'defaultAxesXGrid','on', 'defaultAxesYGrid','on', ...
    'defaultAxesBox','on', 'defaultFigureColor','w', 'defaultLegendFontSize',9);
end

function save_fig(fig, name)
exportgraphics(fig, [name '.png'], 'Resolution', 300);
exportgraphics(fig, [name '.pdf'], 'ContentType', 'vector');
close(fig);
end

function overlay(out, sc, grp, sig, scale, ylab, xl, yl, fname)
idx  = find(strcmp({sc.grp}, grp));
cols = parula(numel(idx) + 1);
fig  = figure('Units','centimeters','Position',[2 2 16 9]); hold on
for j = 1:numel(idx)
    ts = out(idx(j)).get(sig);
    plot(ts.Time, ts.Data*scale, 'Color', cols(j,:), 'DisplayName', sprintf('%d °C', sc(idx(j)).T_init));
end
xlabel('Tiempo [s]'); ylabel(ylab); xlim(xl); ylim(yl); legend('Location','eastoutside');
save_fig(fig, fname);
ends