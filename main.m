%% SISTEMA DE CORRECCIÓN DE ENTONACIÓN DE VOZ
% Proyecto 3 - Biometría de la Voz
% Descripción: Corregir la entonación de un fragmento de voz mediante
% detección de actividad de voz, sonoridad, y análisis LPC

clear all; close all; clc;

%% CONFIGURACIÓN
audioFile = 'audio/digitos.wav';
fs = 16000;                    % Frecuencia de muestreo (Hz)
frameLength = 0.025;           % Longitud de frame (s)
frameSamples = round(frameLength * fs);  % Número de muestras por frame
frameDuration = frameLength;   % Duración de frame en segundos
pitchShift = 1.2;              % Factor de modificación de pitch (1.2 = +20%)
lpcOrder = 12;                 % Orden de LPC

%% 1. CARGA DE AUDIO
fprintf('=== SISTEMA DE CORRECCIÓN DE ENTONACIÓN ===\n');
fprintf('Cargando audio...\n');
[signal, fs] = loadAudio(audioFile);
fprintf('  ✓ Audio cargado: %d muestras, fs = %d Hz, duración = %.2f s\n', ...
    length(signal), fs, length(signal)/fs);
plotSignal(signal, fs, 'Señal Original');

%% 2. PREPROCESAMIENTO
fprintf('Preprocesando señal...\n');
signal = preprocessSignal(signal, fs, 'HPF', 50);
plotSignal(signal, fs, 'Señal Preprocesada');

%% 3. DETECCIÓN DE ACTIVIDAD DE VOZ (VAD)
fprintf('Detectando actividad de voz...\n');
[voiceActive, params_vad] = detectVoiceActivity(signal, fs);
fprintf('Frames con voz detectados: %d/%d\n', sum(voiceActive), length(voiceActive));

%% 4. DETECCIÓN DE SONORIDAD
fprintf('Analizando sonoridad...\n');
[isVoiced, F0, voicing_confidence] = detectVoicing(signal, fs, voiceActive);
fprintf('Estadísticas de F0 - Media: %.2f Hz, Min: %.2f Hz, Max: %.2f Hz\n', ...
    mean(F0(F0>0)), min(F0(F0>0)), max(F0(F0>0)));

%% 4.a VISUALIZAR ENERGY/THRESHOLD + VAD
frameRate = 1 / frameDuration;
Nframes = length(params_vad.energyNorm);
timeFrames = ((1:Nframes) - 0.5) * frameDuration;

figure;
plot(timeFrames, params_vad.energyNorm, '-k', 'LineWidth', 1);
hold on;
plot(timeFrames, repmat(params_vad.energyThreshold, 1, Nframes), '--r', 'LineWidth', 1.2);
plot(timeFrames, repmat(params_vad.energyHigh, 1, Nframes), '--g', 'LineWidth', 1.0);
stairs(timeFrames, voiceActive * 0.25 + 0.1, 'b-', 'LineWidth', 1.5);
legend('Energía normalizada', 'Umbral VAD', 'Umbral alto', 'VAD (scaled)');
title('Detección de voz: energía normalizada + umbrales');
xlabel('Tiempo (s)');
ylabel('Energía normalizada / VAD');
ylim([0, 1.1]);
grid on;

%% 4.b VISUALIZAR VOICING + CONFIDENCE
figure;
plot(timeFrames, isVoiced, '-b','LineWidth',1.5); hold on;
plot(timeFrames, voicing_confidence, '-r','LineWidth',1);
yline(0.5, '--k', 'Umbral confianza');
legend('isVoiced', 'confidence', 'threshold');
title('Detección de historial de sonoridad (voicing)');
xlabel('Tiempo (s)');
ylabel('Binario / Confianza');
ylim([-0.1, 1.1]);
grid on;

%% 5. ANÁLISIS LPC
fprintf('Realizando análisis LPC (orden=%d)...\n', lpcOrder);
[lpcCoeffs, residual, gain] = computeLPC(signal, fs, lpcOrder);

%% 5.a VISUALIZAR ANÁLISIS LPC
numFrames_lpc = size(lpcCoeffs, 1);
timeFrames_lpc = ((1:numFrames_lpc) - 0.5) * frameDuration;

figure;
subplot(2,1,1);
imagesc(20*log10(abs(residual)+eps));
colorbar;
title('Residual LPC (dB)');
xlabel('Muestra en frame');
ylabel('Frame');

subplot(2,1,2);
plot(timeFrames_lpc, 20*log10(gain+eps), '-b', 'LineWidth', 1);
title('Ganancia LPC (dB)');
xlabel('Tiempo (s)');
ylabel('Ganancia (dB)');
grid on;

%% 6. MODIFICACIÓN EN DOMINIO DEL TIEMPO
fprintf('Modificando pitch en dominio del tiempo...\n');
signalModified = modifyPitch(signal, fs, isVoiced, pitchShift);

%% 7. ANÁLISIS LPC DE LA SEÑAL MODIFICADA
fprintf('Recomponiendo señal...\n');
signalReconstructed = reconstructSignal(signalModified, fs, lpcCoeffs, lpcOrder, gain);

%% 8. VISUALIZACIÓN DE RESULTADOS
plotSignal(signalModified, fs, 'Señal Modificada');
plotSignal(signalReconstructed, fs, 'Señal Reconstruida');

figure;
subplot(3,1,1);
plot(timeFrames, F0, '-b', 'LineWidth', 1.5);
title('Contorno de F0 (Frecuencia Fundamental)');
xlabel('Tiempo (s)');
ylabel('Frecuencia (Hz)');
ylim([0, 500]);
grid on;

subplot(3,1,2);
stairs(timeFrames, voiceActive, '-r', 'LineWidth', 1.5);
title('Actividad de Voz');
xlabel('Tiempo (s)');
ylabel('Actividad');
ylim([-0.1, 1.1]);
grid on;

subplot(3,1,3);
plot(timeFrames, voicing_confidence, '-g', 'LineWidth', 1);
title('Confianza de Sonoridad');
xlabel('Tiempo (s)');
ylabel('Confianza');
grid on;

%% 9. GUARDAR RESULTADOS
fprintf('Guardando resultados...\n');
audiowrite('output/signal_modified.wav', signalModified, fs);
audiowrite('output/signal_reconstructed.wav', signalReconstructed, fs);

fprintf('\n=== PROCESO COMPLETADO ===\n');
