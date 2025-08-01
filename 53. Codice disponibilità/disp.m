%%  Codice per il calcolo della disponibiltà

%%  0. Inizializzazione
clc
clear all
close all

%%  1. Data in
Table = readtable("DatiTrend7_20230201_103027.csv");
TempLocal = Table.LocalCol;
TempGMT = Table.TimeCol;

t1 = TempGMT(2);
t2 = TempGMT(3);
dt = t2 - t1;

P = double(strrep(Table.PLC1_AI_POT_ATTIVA,",","."));
Bar = double(strrep(Table.PLC1_AI_PT_LINEA, ",", "."));
LivOp = double(strrep(Table.PLC1_AI_LT_BACINO, ",", "."));
LivCap = double(strrep(Table.PLC1_AI_LT_BACINO2, ",", "."));

%%  2. Definizione controlli

hOn =8;
hOff = 21;

BarRif = 29;
LivOPRif = 22;
LivCaPRif = 16;
PRif = 1;


%%  3. Elaborazione dati

t0 = datetime(TempLocal(2), "InputFormat", "dd/MM/uuuu HH:mm:ss", "InputFormat", ...
    "dd/MM/uuuu HH:mm:ss");

% t = datetime.empty(length(TempLocal),0);

% dt = minutes(15);

tDen = 0;
tNum = 0;

t(1,1)  = t0;

for i =1:length(TempLocal)

    % incremento denominatore
    if hour(t(i,1)) >= hOn | hour(t(i,1)) < hOff
        if Bar >= BarRif & LivOp >= LivOPRif & LivCap >= LivCaPRif

            tDen = tDen + 1;

            if P>PRif
                tNum = tNum + 1;
            end

        end

    else
        if LivOp >= LivOPRif && LivCap >= LivCaPRif

            tDen = tDen + 1;

            if P > PRif
                tNum = tNum + 1;
            end

        end
    end

    t(i,1) = t0 + dt;
    t0 = t(i,1);




    % controllo P>1

    % controllo condizioni:
    %   1. Pressione di linea > 29 bar
    %   2. Livello op. di presa > 22 (2,2 m)
    %   3. Livello ca' Previtali > 16 m
    %   4. ore tra le 08:00 e le 21:00 valide 1,2 e 3
    %   5. ore tra le 21:00 e le 08:00 valide 2 e 3
end

%%  3.  Output

Disp = tNum/tDen;