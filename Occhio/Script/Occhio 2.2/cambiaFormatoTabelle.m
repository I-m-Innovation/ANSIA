clc
close all
clear all

% TVecchia = readtable('PGTEMP.csv');
% 
% writetable(TVecchia,'TempXLSX.xlsx');

% RigheNuove=readtable("DATI_202301300800.csv");
% 
% writetable(RigheNuove,'newLine.xlsx');

tabToConvert=readtable("TempXLSX.xlsx");
writetable(tabToConvert,'Template.csv');