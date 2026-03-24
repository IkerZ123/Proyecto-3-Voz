%% SISTEMA DE CORRECCIÓN DE ENTONACIÓN DE VOZ
% Proyecto 3 - Biometría de la Voz
% Descripción: Corregir la entonación de un fragmento de voz mediante
% detección de actividad de voz, sonoridad, y análisis LPC

clear all; close all; clc;

%% CONFIGURACIÓN
audioFile = 'audio/sample.wav';
fs = 16000;                    % Frecuencia de muestreo (Hz)
frameLength = 0.025;           % Longitud de frame (s)
frameDuration = round(frameLength * fs);
pitchShift = 1.2;              % Factor de modificación de pitch (1.2 = +20%)
lpcOrder = 12;                 % Orden de LPC

%% 1. CARGA DE AUDIO
fprintf('=== SISTEMA DE CORRECCIÓN DE ENTONACIÓN ===\n');
fprintf('Cargando audio...\n');
[signal, fs] = loadAudio(audioFile);
plotSignal(signal, fs, 'Señal Original');

%% 2. PREPROCESAMIENTO
fprintf('Preprocesando señal...\n');
signal = preprocessSignal(signal);

%% 3. DETECCIÓN DE ACTIVIDAD DE VOZ (VAD)
fprintf('Detectando actividad de voz...\n');
[voiceActive, params_vad] = detectVoiceActivity(signal, fs);
fprintf('Frames con voz detectados: %d/%d\n', sum(voiceActive), length(voiceActive));

%% 4. DETECCIÓN DE SONORIDAD
fprintf('Analizando sonoridad...\n');
[isVoiced, F0, voicing_confidence] = detectVoicing(signal, fs, voiceActive);
fprintf('Estadísticas de F0 - Media: %.2f Hz, Min: %.2f Hz, Max: %.2f Hz\n', ...
    mean(F0(F0>0)), min(F0(F0>0)), max(F0(F0>0)));

%% 5. ANÁLISIS LPC
fprintf('Realizando análisis LPC (orden=%d)...\n', lpcOrder);
[lpcCoeffs, residual, gain] = computeLPC(signal, fs, lpcOrder);

%% 6. MODIFICACIÓN EN DOMINIO DEL TIEMPO
fprintf('Modificando pitch en dominio del tiempo...\n');
signalModified = modifyPitch(signal, fs, isVoiced, pitchShift);

%% 7. ANÁLISIS LPC DE LA SEÑAL MODIFICADA
fprintf('Recomponiendo señal...\n');
signalReconstructed = reconstructSignal(signalModified, fs, lpcCoeffs, lpcOrder);

%% 8. VISUALIZACIÓN DE RESULTADOS
plotSignal(signalModified, fs, 'Señal Modificada');
plotSignal(signalReconstructed, fs, 'Señal Reconstruida');

figure;
subplot(3,1,1);
plot(F0); title('Contorno de F0 (Frecuencia Fundamental)');
xlabel('Frame'); ylabel('Frecuencia (Hz)');

subplot(3,1,2);
plot(voiceActive); title('Actividad de Voz');
xlabel('Frame'); ylabel('Actividad');
ylim([-0.1, 1.1]);

subplot(3,1,3);
plot(voicing_confidence); title('Confianza de Sonoridad');
xlabel('Frame'); ylabel('Confianza');

%% 9. GUARDAR RESULTADOS
fprintf('Guardando resultados...\n');
audiowrite('output/signal_modified.wav', signalModified, fs);
audiowrite('output/signal_reconstructed.wav', signalReconstructed, fs);

fprintf('\n=== PROCESO COMPLETADO ===\n');
