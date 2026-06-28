clc; clear; close all;

wn = 1;
zeta = 2;

figure;
G = tf([wn^2], [1, 2*zeta*wn, wn^2]);
step(G);
xlim([0, 20]);


G1 = tf([1], [1, -0.5, 4]);
G2 = tf([1], [25, -12.5, 1]);
figure;

%oscilante
subplot(2,2,1); 
step(G1, 30);
subplot(2,2,3); 
pzmap(G1);

%no Oscilante
subplot(2,2,2); 
step(G2, 30);
subplot(2,2,4); 
pzmap(G2);