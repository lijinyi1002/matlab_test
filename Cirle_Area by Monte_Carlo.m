clc 
clear
close all

N = 5000;
a = -1;
b = 1;
r = 1;
x = a + (b-a).*rand(N,1); % ���ox�b-1~1�������üư}�C
y = a + (b-a).*rand(N,1); % ���oy�b-1~1�������üư}�C
s = sqrt(x.^2 + y.^2); % ����ڤ����A�p��(x,y)�P(0�A0)���Z��

i = s<=1; % i���@�޿�}�C�A�p�G<=1�h���u(1)�A�Ϥ������u(0)
plot(x(i) , y(i) ,'k.') % �ץX�ꤺ���I(�t��W)�Ak.���¦��I
hold % ��ϦX��
plot(x(~i) , y(~i) , 'b.') % �ץX��~���I�Ab.���¦��I
axis equal;


inside = sum(i); % �p��ꤺ(�t��W)�I�ƶq
outside = sum(~i);  % �p���~�I�ƶq


answer = (inside/N)*(2*r)^2 % ���p���ꭱ�n
actual = pi*r^2 % ��ڤ������ꭱ�n

ttl = sprintf('Estimate Actual Area of circle: %1.3f, Actual Area of the circle: %1.3f',answer,actual);
title(ttl);









    