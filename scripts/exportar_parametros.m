%% exportar_parametros.m - registro de parametros del estudio termico
% USO: ejecuta primero init_HEMS.m (las variables deben estar en el workspace)
%      y despues este script. Genera Registro_parametros_AAAA-MM-DD.xlsx
%
% Columnas: Nombre | Descripcion | Valor | Unidad | Esperado | Comprobacion | Fuente | Estado
% - Valor y Comprobacion se rellenan solos desde el workspace.
% - Esperado es el valor de referencia (tabla de hilos, TFG, guia); NaN = no hay referencia.
% - Fuente y Estado son los que tienes que completar a mano en el Excel.

pr_def = {
    % nombre       descripcion                                   unidad   esperado   fuente                         estado
    'R_coil'      'Resistencia bobina a T_ref_R'                'ohm'    1.28       'modelo (sin medir)'           'pendiente: medir'
    'L_coil'      'Inductancia bobina'                          'H'      NaN        'FEM / TFG'                    'revisar'
    'S_cu'        'Seccion del hilo (12 AWG, 2.000 mm)'         'm2'     3.142e-6   'tabla hilos esmaltados'       'confirmado'
    'rho_cu'      'Resistividad del cobre'                      'ohm*m'  1.71e-8    'tabla hilos / guia'           'confirmado'
    'alpha_cu'    'Coef. de temperatura del cobre'              '1/K'    3.9e-3     'guia; TFG da 3.93e-3'         'confirmado'
    'd_cu'        'Densidad del cobre'                          'kg/m3'  8900       'guia'                         'confirmado'
    'cp_cu'       'Calor especifico del cobre'                  'J/kg/K' 380        'guia (tipico 385)'            'confirmado'
    'l_wire'      'Longitud del hilo (calculada de R_coil)'     'm'      NaN        'calculo'                      'pendiente: confirmar'
    'm_coil'      'Masa de cobre (calculada)'                   'kg'     NaN        'calculo'                      'pendiente: confirmar'
    'C_th'        'Capacidad termica m_coil*cp_cu'              'J/K'    NaN        'calculo'                      'depende de m_coil'
    'T_ref_R'     'Temperatura a la que vale R_coil'            'degC'   25         'guia'                         'pendiente: confirmar'
    'T_ref_mag'   'Temperatura de referencia de los imanes'     'degC'   25         'guia'                         'confirmado'
    'T_amb'       'Temperatura ambiente'                        'degC'   25         'guia'                         'confirmado'
    'T_lim_coil'  'Limite termico del esmalte'                  'degC'   NaN        'provisional (guia 155)'       'pendiente: etiqueta/pedido'
    'T_lim_mag'   'Limite termico del iman N42'                 'degC'   80         'provisional (tipico N42)'     'pendiente: ficha'
    'beta_Br'     'Coef. de temperatura de la remanencia (escenario)' '1/K' NaN     'tipico NdFeB -1.1e-3'         'pendiente: ficha'
    'beta_ki'     'Perdida de eficacia de la bobina (escenario)' '1/K'   NaN        'hipotesis'                    'pendiente: Miquel/FEM'
    'G_cool'      'Refrigeracion'                               'W/K'    0          'peor caso'                    'pendiente: responsable'
    'k_acc'       'Aceleracion del tiempo termico'              '-'      NaN        'escenario'                    'escenario'
    'thermal_on'  'Calentamiento activo (0/1)'                  '-'      NaN        'escenario'                    'escenario'
    'T_init'      'Temperatura inicial'                         'degC'   NaN        'escenario'                    'escenario'
    'F_load'      'Carga extra'                                 'N'      NaN        'escenario'                    'escenario'
    't_step'      'Instante del escalon de referencia'          's'      3          'guia'                         'confirmado'
    't_load'      'Instante del escalon de carga'               's'      6          'guia'                         'confirmado'
    't_sim'       'Duracion de la simulacion'                   's'      NaN        'guia'                         'revisar'
    'm'           'Masa levitada'                               'kg'     NaN        'modelo'                       'revisar'
    'g0'          'Gravedad'                                    'm/s2'   9.81       'modelo'                       'confirmado'
    'z0'          'Entrehierro de equilibrio'                   'm'      0.01636    'TFG (16.36 mm)'               'confirmado'
    'ki'          'Ganancia fuerza/corriente'                   'N/A'    NaN        'FEM'                          'revisar'
    'a2'          'Rigidez negativa (parte del iman)'           '1/s2'   NaN        'linealizacion'                'revisar'
    'b'           'Ganancia fuerza/corriente linealizada'       '-'      NaN        'linealizacion'                'revisar'
    'I_max'       'Corriente maxima del actuador'               'A'      55         'TFG'                          'confirmado'
    'V_max'       'Tension maxima (bus)'                        'V'      NaN        'TFG (bus 400 V)'              'revisar'
    'Kp_cur'      'Ganancia Kp lazo de corriente'               '-'      NaN        'diseno'                       'diseno'
    'Ki_cur'      'Ganancia Ki lazo de corriente'               '-'      NaN        'diseno'                       'diseno'
    'Kp_pos'      'Ganancia Kp lazo de posicion'                '-'      NaN        'diseno'                       'diseno'
    'Ki_pos'      'Ganancia Ki lazo de posicion'                '-'      NaN        'diseno'                       'diseno'
    'Kd_pos'      'Ganancia Kd lazo de posicion'                '-'      NaN        'diseno'                       'diseno'
    'N_pos'       'Filtro de la derivada'                       'rad/s'  NaN        'diseno'                       'diseno'
    'airgap_bp'   'Rango de la tabla de fuerza (entrehierro)'   'm'      NaN        'FEM (JMAG)'                   'revisar'
    'current_bp'  'Rango de la tabla de fuerza (corriente)'     'A'      NaN        'FEM (JMAG)'                   'revisar'
    };

n = size(pr_def, 1);
Nombre = pr_def(:,1);  Descripcion = pr_def(:,2);  Unidad = pr_def(:,3);
Esperado = cell2mat(pr_def(:,4));  Fuente = pr_def(:,5);  Estado = pr_def(:,6);
Valor = cell(n,1);  Comprobacion = cell(n,1);

for pr_k = 1:n
    pr_name = pr_def{pr_k,1};
    if ~exist(pr_name, 'var')
        Valor{pr_k} = 'NO ENCONTRADA';  Comprobacion{pr_k} = 'revisar nombre en init_HEMS.m';
        continue
    end
    pr_v = eval(pr_name);
    if isnumeric(pr_v) && isscalar(pr_v)
        Valor{pr_k} = pr_v;
        if ~isnan(Esperado(pr_k))
            if abs(pr_v - Esperado(pr_k)) <= 0.01*abs(Esperado(pr_k))
                Comprobacion{pr_k} = 'OK';
            else
                Comprobacion{pr_k} = 'REVISAR (distinto del esperado)';
            end
        else
            Comprobacion{pr_k} = '-';
        end
    elseif isnumeric(pr_v)
        Valor{pr_k} = sprintf('%d valores, de %.4g a %.4g', numel(pr_v), min(pr_v(:)), max(pr_v(:)));
        Comprobacion{pr_k} = '-';
    else
        Valor{pr_k} = class(pr_v);  Comprobacion{pr_k} = '-';
    end
end

Fecha = repmat({datestr(now, 'yyyy-mm-dd')}, n, 1);
Tabla = table(Nombre, Descripcion, Valor, Unidad, Esperado, Comprobacion, Fuente, Estado, Fecha);
disp(Tabla(:, {'Nombre','Valor','Unidad','Comprobacion'}))

pr_file = ['Registro_parametros_' datestr(now, 'yyyy-mm-dd') '.xlsx'];
writetable(Tabla, pr_file);
fprintf('\nGuardado: %s (%d parametros, %d con aviso)\n', pr_file, n, ...
    sum(startsWith(Comprobacion, 'REVISAR') | strcmp(Comprobacion, 'revisar nombre en init_HEMS.m')));