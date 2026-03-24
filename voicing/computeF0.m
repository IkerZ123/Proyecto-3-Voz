function [F0, f0Conf] = computeF0(signal, fs, frameDuration)
    % COMPUTEF0 Estimación de Frecuencia Fundamental (F0)
    %
    %   Sintaxis:
    %       [F0, f0Conf] = computeF0(signal, fs)
    %       [F0, f0Conf] = computeF0(signal, fs, frameDuration)
    %
    %   Entrada:
    %       signal (vector): Señal de audio
    %       fs (int): Frecuencia de muestreo (Hz)
    %       frameDuration (float, opcional): Duración de frame (s), default 0.025
    %
    %   Salida:
    %       F0 (vector): Frecuencia fundamental por frame (Hz)
    %       f0Conf (vector): Confianza (pico ACF normalizado)

    if nargin < 3
        frameDuration = 0.025;
    end
    frameSamples = round(frameDuration * fs);

    minF0 = 50;  % Hz
    maxF0 = 500; % Hz
    minLag = round(fs / maxF0);
    maxLag = round(fs / minF0);

    numFrames = floor(length(signal) / frameSamples);
    F0 = zeros(numFrames, 1);
    f0Conf = zeros(numFrames, 1);

    for i = 1:numFrames
        frameStart = (i-1) * frameSamples + 1;
        frameEnd = frameStart + frameSamples - 1;
        frame = signal(frameStart:frameEnd);

        % Ventana Hamming
        frame = frame .* hamming(frameSamples);

        % Validación de energía básica
        if mean(frame .^ 2) < 1e-6
            F0(i) = 0;
            f0Conf(i) = 0;
            continue;
        end

        % Calcular autocorrelación
        acf = computeACF(frame, maxLag);

        % Buscar primer pico local en rango válido
        [pico, relIdx] = max(acf(minLag:maxLag));
        lag = minLag + relIdx - 1;

        % Determinar F0 y confianza
        f0Candidate = fs / lag;
        f0Conf(i) = pico;

        if pico < 0.30 || f0Candidate < minF0 || f0Candidate > maxF0
            F0(i) = 0;
            f0Conf(i) = 0;
        else
            F0(i) = f0Candidate;
        end
    end
end
