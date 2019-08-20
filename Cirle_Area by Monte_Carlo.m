clc 
clear
close all

N = 5000;
a = -1;
b = 1;
r = 1;
x = a + (b-a).*rand(N,1); % 取得x在-1~1之間之亂數陣列
y = a + (b-a).*rand(N,1); % 取得y在-1~1之間之亂數陣列
s = sqrt(x.^2 + y.^2); % 平方根公式，計算(x,y)與(0，0)之距離

i = s<=1; % i為一邏輯陣列，如果<=1則為真(1)，反之不為真(0)
plot(x(i) , y(i) ,'k.') % 匯出圓內的點(含圓上)，k.為黑色點
hold % 兩圖合併
plot(x(~i) , y(~i) , 'b.') % 匯出圓外的點，b.為黑色點
axis equal;


inside = sum(i); % 計算圓內(含圓上)點數量
outside = sum(~i);  % 計算圓外點數量


answer = (inside/N)*(2*r)^2 % 估計的圓面積
actual = pi*r^2 % 實際公式之圓面積

ttl = sprintf('Estimate Actual Area of circle: %1.3f, Actual Area of the circle: %1.3f',answer,actual);
title(ttl);









    