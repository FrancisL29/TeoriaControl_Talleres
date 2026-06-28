clc; clear; close all;

num_estable = [1];
den_estable = [2 1];
G_estable = tf(num_estable, den_estable);
polos_estable = roots(den_estable);

figure;
subplot(1,2,1);
[y_est, t_est] = step(G_estable);
plot(t_est, y_est);
hold on;

tau = 2;
t_4tau = 4 * tau;
y_4tau = step(G_estable, t_4tau);
plot(t_4tau, y_4tau(end), 'ro', 'MarkerSize', 6, 'MarkerFaceColor', 'r');