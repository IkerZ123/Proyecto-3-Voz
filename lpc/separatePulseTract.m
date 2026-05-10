function [pulse, tract, lpcMatrix] = separatePulseTract(signal, fs, l_v, n_coef, pole)
% SEPARATEPULSETTRACT Separa pulso y tracto vocal por filtrado inverso en bloques
%
%   [pulse, tract, lpcMatrix] = separatePulseTract(signal, fs, l_v, n_coef, pole)
%
%   signal   : señal de audio en vectores columna
%   fs       : frecuencia de muestreo
%   l_v      : longitud de ventana (muestras)
%   n_coef   : orden LPC
%   pole     : polo de preénfasis
%
%   pulse    : señal residual / pulso glótico
%   tract    : respuesta del tracto vocal reconstruida
%   lpcMatrix: coeficientes LPC por bloque

if nargin < 5
    pole = 0.95;
end

signal = signal(:);

if length(signal) < l_v
    error('La señal debe ser más larga que la longitud de ventana.');
end

desplaza = l_v / 2;
n_trozos = floor((length(signal) - l_v) / desplaza) + 1;

% Preénfasis en la señal completa antes del análisis
signalEmph = filter([1 -pole], 1, signal);
window = hamming(l_v, 'periodic');

pulse = zeros(length(signal), 1);
tract = zeros(length(signal), 1);
normPulse = zeros(length(signal), 1);
normTract = zeros(length(signal), 1);
lpcMatrix = zeros(n_coef+1, n_trozos);

for i = 1:n_trozos
    idx = (i-1) * desplaza + 1;
    frame = signalEmph(idx:idx + l_v - 1) .* window;

    a_lpc = real(lpc(frame, n_coef));
    lpcMatrix(:, i) = a_lpc(:);

    % Pulso glótico: aplicar filtro inverso LPC al segmento en ventanado
    residual = filter(1, a_lpc, frame);
    pulse(idx:idx + l_v - 1) = pulse(idx:idx + l_v - 1) + residual;
    normPulse(idx:idx + l_v - 1) = normPulse(idx:idx + l_v - 1) + window;

    % Tracto vocal: respuesta al impulso del filtro LPC
    h_tract = impz(1, a_lpc, l_v);
    tract(idx:idx + l_v - 1) = tract(idx:idx + l_v - 1) + h_tract .* window;
    normTract(idx:idx + l_v - 1) = normTract(idx:idx + l_v - 1) + window;
end

pulse = pulse ./ (normPulse + eps);
tract = tract ./ (normTract + eps);
end
