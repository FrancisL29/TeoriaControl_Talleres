close all; clear; clc;

%% TAREA 1: Cargar datos y graficar
table = readtable("data_motor.csv");
tM = table.time_t_;
uM = table.ex_signal_u_;
yM = table.system_response_y_;

figure
plot(tM, uM, 'b', tM, yM, 'r', 'LineWidth', 1.5);
xlabel('Tiempo (s)'); ylabel('Amplitud');
title('Respuesta del sistema ante escalón');
legend('Escalón u(t)', 'Respuesta y(t)');
grid on;

%% TAREA 2: Línea base, línea 100%, recta tangente
y_base = 0;
y_ss = mean(yM(end-20:end));
u_step = max(uM);
K = (y_ss - y_base) / u_step;

% Dos puntos en la zona lineal (~20% y ~50% del valor final)
[~, i1] = min(abs(yM - 0.20*y_ss));
[~, i2] = min(abs(yM(i1:end) - 0.50*y_ss));
i2 = i2 + i1 - 1;

m = (yM(i2) - yM(i1)) / (tM(i2) - tM(i1));
t_base = tM(i1) + (y_base - yM(i1)) / m;   % corte con línea base
t_ss   = tM(i1) + (y_ss - yM(i1)) / m;     % corte con línea 100%

% Recta tangente para graficar
t_tang = linspace(t_base - 0.05, t_ss + 0.05, 100);
y_tang = yM(i1) + m*(t_tang - tM(i1));

figure
plot(tM, yM, 'r', tM, uM, 'g', 'LineWidth', 1.5); hold on;
yline(y_base, 'k--'); yline(y_ss, 'k--');
plot(t_tang, y_tang, 'b', 'LineWidth', 1.8);
plot(tM([i1 i2]), yM([i1 i2]), 'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'y');
xlabel('Tiempo (s)'); ylabel('Amplitud');
title('Líneas de referencia y recta tangente');
legend('y(t)', 'u(t)', 'Línea base', 'Línea 100%', 'Tangente', 'Puntos');
grid on;

%% TAREA 3: Métodos de identificación

% Tiempos al 28.3% y 63.2%
y_283 = 0.283 * y_ss;
y_632 = 0.632 * y_ss;
% interp1 interpola linealmente para encontrar el tiempo exacto
i283 = find(yM >= y_283, 1);
t_283 = interp1(yM(i283-1:i283), tM(i283-1:i283), y_283);
i632 = find(yM >= y_632, 1);
t_632 = interp1(yM(i632-1:i632), tM(i632-1:i632), y_632);

% Ajuste Manual
ajuste = 0.2;

% Ziegler & Nichols
theta_zn = t_base - ajuste;
tau_zn = t_ss - t_base;
G_zn = tf(K, [tau_zn 1], 'InputDelay', theta_zn);
ym_zn = lsim(G_zn, uM, tM);
fit_zn = 100*(1 - norm(yM - ym_zn)/norm(yM - mean(yM)));

% Miller
tau_mi = (3/2)*(t_632 - t_283);
theta_mi = t_632 - tau_mi - ajuste;
G_mi = tf(K, [tau_mi 1], 'InputDelay', theta_mi);
ym_mi = lsim(G_mi, uM, tM);
fit_mi = 100*(1 - norm(yM - ym_mi)/norm(yM - mean(yM)));

% Analítico
c1 = -log(1 - 0.283);
c2 = -log(1 - 0.632);
tau_an = (t_632 - t_283) / (c2 - c1);
theta_an = t_283 - c1*tau_an - ajuste;
G_an = tf(K, [tau_an 1], 'InputDelay', theta_an);
ym_an = lsim(G_an, uM, tM);
fit_an = 100*(1 - norm(yM - ym_an)/norm(yM - mean(yM)));

% Gráfico comparativo
figure
plot(tM, yM, 'b', 'LineWidth', 1.8); hold on;
plot(tM, ym_zn, 'r', 'LineWidth', 1.2);
plot(tM, ym_mi, 'm--', 'LineWidth', 1.2);
plot(tM, ym_an, 'c-.', 'LineWidth', 1.2);
plot(tM, uM, 'g', 'LineWidth', 1);
yline(y_base, 'k--'); yline(y_ss, 'k--');
xlabel('Tiempo (s)'); ylabel('Amplitud');
title('Identificación Gráfica - Comparación');
legend('Proceso', ...
       sprintf('Z&N (%.1f%%)', fit_zn), ...
       sprintf('Miller (%.1f%%)', fit_mi), ...
       sprintf('Analítico (%.1f%%)', fit_an), ...
       'Escalón', 'Base', '100%');
grid on;

% Resumen
fprintf('\n  Método              K       tau     theta    Fit\n');
fprintf('  Ziegler & Nichols  %.4f  %.4f  %.4f   %.2f%%\n', K, tau_zn, theta_zn, fit_zn);
fprintf('  Miller             %.4f  %.4f  %.4f   %.2f%%\n', K, tau_mi, theta_mi, fit_mi);
fprintf('  Analítico          %.4f  %.4f  %.4f   %.2f%%\n', K, tau_an, theta_an, fit_an);