clc; clear; close all;

G1 = tf([3], [1 0]);
G2 = tf([1], [1 0 1])
H1 = 3;

Gs = series(G1, G2);
Gf = feedback(Gs, H1);
figure;
step(Gf);
figure;
pzmap(Gf);

[num_cl, den_cl] = tfdata(Gf, 'v')

polos_cl = roots(den_cl);
disp(polos_cl);