# Ten_Bar_Truss作業說明

在Matlab中，總共有個.m檔，分別是"get_tenbar_result"、"main"、"nonlcon"、"obj"、"get_length"、"get_sincos"，其中只有"main"是script底稿，其餘皆為function函式。以下分別說明各檔案的功能:

---

* ## get_tenbar_result

此函式的輸入為半徑，而輸出為stress與disp，這兩輸出參數將建立限制條件。以下說明該函式的流程。

1. 定義楊式係數E為200GPa，並建立每個node的座標
```
E = 200E+9; % Pa
node = [18.28,9.14;18.28,0;9.14,9.14;9.14,0;0,9.14;0,0 ];
```
2. 透過三個for迴圈，取得個元素的半徑r以及運算個元素的面積area

```
for c = 1:6
    r(c) = x(1);
end
```
```
for c = 7:10
    r(c) = x(2);
end
```
```
for c = 1:10
    area(c) = pi*r(c)^2;
end
```
3. 建立每個元素兩邊的node編號矩陣conects，並利用for迴圈，透過get_length計算元素長度length，與透過get_sincos取得每個元素對應的sin和cos值sc
```
connects = [5,3; 3,1; 6,4; 4,2; 4,3; 2,1; 5,4; 6,3; 3,2; 4,1];

length = [];
for row = 1:10
    n1 = connects(row,1);
    n2 = connects(row,2);
    length = [length; get_length(node(n1,1), node(n1,2), node(n2,1), node(n2,2))];
end
```
```
sc = [];
for row = 1:10
    n1 = connects(row,1);
    n2 = connects(row,2);
    [s, c] =  get_sincos(node(n1,1), node(n1,2), node(n2,1), node(n2,2), length(row));
    sc = [sc; s, c];
end
```
4. 建立剛性矩陣K。為了使for迴圈流程精簡，首先建立node矩陣，接著透過for迴圈，計算K
```
or cn = 1:10
    k = [sc(cn,2).^2, sc(cn,2).*sc(cn,1), -sc(cn,2).^2, -sc(cn,1).*sc(cn,2);
         sc(cn,1).*sc(cn,2), sc(cn,1).^2, -sc(cn,2).*sc(cn,1), -sc(cn,1).^2;
        -sc(cn,2).^2, -sc(cn,2).*sc(cn,1), sc(cn,2).^2, sc(cn,2).*sc(cn,1);
        -sc(cn,2).*sc(cn,1), -sc(cn,1).^2, sc(cn,2).*sc(cn,1), sc(cn,1).^2];
    ke = zeros(12, 12);
    ke([nodes(cn,:)], [nodes(cn,:)]) = (E*area(cn)/length(cn)).*k;
    K = K + ke; % 剛性矩陣
end


K([9,10,11,12],:) = [];
K(:,[9,10,11,12]) = [];
```
5. 利用f=kq計算位移矩陣q，並以disp取代q
```
f = [0;0;0;-1e7;0;0;0;-1e7] ; % 外力(N)
q = K\f; % 位移矩陣
q(9:12) = 0;
disp = q;

```
6. 最後一步則是計算應力stress
```
stress = [];
qq = [];
Q = [];
for cn = 1:10
    for count = nodes(cn,:)
        qq = [qq,q(count)];
    end
    Q = [ Q ; qq ];
    qq = [];
    stress = [stress ; (E/length(cn,:))*([-sc(cn,2), -sc(cn,1), sc(cn,2), sc(cn,1)]*Q(cn, :).')]; % 應力矩陣
end
```

---

* ## nonlcon

透過get_tenbar_result函式，輸出disp與stress，用此兩參數來建立條件限制，限制分別是"每個元素的應力小於等於降伏強度20MPa"、"node的位移必須小於0.02m"
```
function [c, ceq] = nonlcon(x)

[disp, stress] = get_tenbar_result(x);

stress_limit = 250*1e+6; % Pa
disp_limit = 0.02; % m

c_stress = abs(stress) - stress_limit;
c_disp = sqrt(disp(3)^2 + disp(4)^2) - disp_limit;

c = [c_stress; c_disp*1e+8]; 
ceq = [];

```

---

* ## obj

1. 是先透過運算取得目標函是所需的長度length和半徑r參數
```
for c = 1:6
    r(c) = x(1);
end

for c = 7:10
    r(c) = x(2);
end

connects = [5,3; 3,1; 6,4; 4,2; 4,3; 2,1; 5,4; 6,3; 3,2; 4,1];
node = [18.28,9.14;18.28,0;9.14,9.14;9.14,0;0,9.14;0,0 ];

length = []; % m
for row = 1:10
    n1 = connects(row,1);
    n2 = connects(row,2);
    length = [length; get_length(node(n1,1), node(n1,2), node(n2,1), node(n2,2))];
end
```
2. 建立目標函式(所有桿件質量最佳化)
```
f = 0; % kg
for i = 1:10
    f = f + pi*r(i)^2*length(i)*7860.0; % 密度 7860 kg/m^3
end
```

---

* ## main

1. 起始店家設為各式0.1，而依照題目，半徑的最佳化範圍是0.001m至0.5m之間
```
x0 = [0.1, 0.1];
ub = [0.5, 0.5];
lb = [0.001, 0.001];
```
2. 以fmincon進行質量最佳化，並輸入obj與nonlcon
```
options = optimset('display', 'iter');

[xopt, fval, exitflag] = fmincon('obj', x0, [], [], [], [], lb, ub, 'nonlcon', options);
```