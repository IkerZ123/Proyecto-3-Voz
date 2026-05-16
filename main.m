%% SISTEMA DE CORRECCIÓN DE ENTONACIÓN DE VOZ
% Proyecto 3 - Biometría de la Voz
% Descripción: Corregir la entonación de un fragmento de voz mediante
% detección de actividad de voz, sonoridad, y análisis LPC

clear all; close all; clc;
addpath(genpath(pwd));

%% CONFIGURACIÓN
audioDir = 'audio';
defaultAudioFile = 'aeiou_femenino.wav';
audioFileName = input(sprintf('Nombre del archivo de audio dentro de %s [%s]: ', audioDir, defaultAudioFile), 's');
if isempty(audioFileName)
    audioFileName = defaultAudioFile;
end

audioFile = fullfile(audioDir, audioFileName);
if ~exist(audioFile, 'file')
    fprintf('Error: no se encontró el archivo "%s". Finalizando programa.\n', audioFile);
    return;
end

[~, audioBaseName] = fileparts(audioFileName);
audioBaseName = strrep(audioBaseName, ' ', '_');
outputDir = 'output';

fs = 16000;                    % Frecuencia de muestreo (Hz)
frameLength = 0.025;           % Longitud de frame (s)
frameSamples = round(frameLength * fs);  % Número de muestras por frame
frameDuration = frameLength;   % Duración de frame en segundos
lpcOrder = 12;                 % Orden de LPC

%% 1. CARGA DE AUDIO
fprintf('=== SISTEMA DE CORRECCIÓN DE ENTONACIÓN ===\n');
fprintf('Cargando audio: %s\n', audioFile);
[signal, fs] = loadAudio(audioFile);
fprintf('  ✓ Audio cargado: %d muestras, fs = %d Hz, duración = %.2f s\n', ...
    length(signal), fs, length(signal)/fs);
% Pedir selección de fragmento al usuario
recomendacionStart = 0.8;
recomendacionEnd = 1.8;
selectionStartTime = input(sprintf('Tiempo de inicio del fragmento a modificar (s) [%.2f]: ', recomendacionStart));
if isempty(selectionStartTime)
    selectionStartTime = recomendacionStart;
end
selectionEndTime = input(sprintf('Tiempo de fin del fragmento a modificar (s) [%.2f]: ', recomendacionEnd));
if isempty(selectionEndTime)
    selectionEndTime = recomendacionEnd;
end
if selectionStartTime < 0
    selectionStartTime = 0;
end
if selectionEndTime > length(signal)/fs
    selectionEndTime = length(signal)/fs;
end
if selectionEndTime < selectionStartTime
    temp = selectionStartTime;
    selectionStartTime = selectionEndTime;
    selectionEndTime = temp;
end

semitoneShift = input('Número de semitonos para ajustar (+agudo, -grave) [2]: ');
if isempty(semitoneShift)
    semitoneShift = 2;
end
if semitoneShift >= 0
    directionText = 'agudo';
else
    directionText = 'grave';
end
pitchShift = 2^(semitoneShift/12);
fprintf('Ajustando la región %.2f-%.2f s hacia %s (%+d semitono(s))\n', ...
    selectionStartTime, selectionEndTime, directionText, semitoneShift);
plotSignal(signal, fs, 'Señal Original');

% Mostrar la región seleccionada para afinación
figure;
time = (0:length(signal)-1) / fs;
plot(time, signal, 'b');
hold on;
yl = ylim();
patch([selectionStartTime selectionEndTime selectionEndTime selectionStartTime], ...
      [yl(1) yl(1) yl(2) yl(2)], [0.9 0.9 0.9], 'FaceAlpha', 0.25, 'EdgeColor', 'none');
plot(time, signal, 'b');
xlabel('Tiempo (s)');
ylabel('Amplitud');
title(sprintf('Señal original con región seleccionada [%.2f, %.2f] s', selectionStartTime, selectionEndTime));
grid on;

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

%% 5.b SEPARACIÓN POR FILTRADO INVERSO
fprintf('Separando pulso y tracto vocal mediante filtrado inverso...\n');

l_v = frameSamples;
n_coef = lpcOrder;
polo = 0.95;
[pulso, tracto, matriz_a_lpc] = separatePulseTract(signal, fs, l_v, n_coef, polo);

if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end
if any(abs(tracto) > 0)
    audiowrite(fullfile(outputDir, sprintf('%s_tracto.wav', audioBaseName)), tracto / max(abs(tracto) + eps), fs);
end

% Generar pulso sintético a partir de F0 para usar en la reconstrucción
pulsoSintetico = synthesizePulseFromF0(F0, isVoiced, fs, length(signal), frameDuration);
if any(abs(pulsoSintetico) > 0)
    audiowrite(fullfile(outputDir, sprintf('%s_pulso_sintetico.wav', audioBaseName)), pulsoSintetico, fs);
end

figure;
timePulso = (0:length(pulso)-1) / fs;
subplot(3,1,1);
plot(timePulso, pulso);
title('Pulso glótico extraído');
xlabel('Tiempo (s)');
ylabel('Amplitud');
grid on;

subplot(3,1,2);
spectrogram(pulso, 256, 128, 512, fs, 'yaxis');
title('Espectrograma del pulso glótico');

subplot(3,1,3);
plot((0:length(pulsoSintetico)-1)/fs, pulsoSintetico);
title('Pulso sintético a partir de F0');
xlabel('Tiempo (s)');
ylabel('Amplitud');
grid on;

figure;
subplot(2,1,1);
spectrogram(tracto, 256, 128, 512, fs, 'yaxis');
title('Espectrograma del tracto vocal extraído');

subplot(2,1,2);
plot((0:length(tracto)-1)/fs, tracto);
title('Tracto vocal extraído en el dominio del tiempo');
xlabel('Tiempo (s)');
ylabel('Amplitud');
grid on;

%% 6. MODIFICACIÓN DEL PULSO Y RECOMPOSICIÓN
fprintf('Modificando el pulso y recomponiendo la señal...\n');

pulseGain = input('Factor de ganancia del pulso [1.0]: ');
if isempty(pulseGain)
    pulseGain = 1.0;
end
pulseCutoff = input('Frecuencia de corte para suavizar el pulso (Hz, 0 = sin filtrar) [0]: ');
if isempty(pulseCutoff)
    pulseCutoff = 0;
end

pulsoMod = pulsoSintetico * pulseGain;
if pulseCutoff > 0
    pulsoMod = lowpass(pulsoMod, pulseCutoff, fs);
end

% Reconstrucción a partir del pulso modificado y el tracto LPC
recomposedFromPulse = zeros(length(signal), 1);
normRecomposed = zeros(length(signal), 1);
window = hamming(l_v, 'periodic');
desplaza = l_v / 2;
numBlocks = size(matriz_a_lpc, 2);

for i = 1:numBlocks
    idx = (i-1) * desplaza + 1;
    segment = pulsoMod(idx:idx + l_v - 1) .* window;
    a_lpc = matriz_a_lpc(:, i);
    reconstructedSegment = filter(1, a_lpc, segment);
    recomposedFromPulse(idx:idx + l_v - 1) = recomposedFromPulse(idx:idx + l_v - 1) + reconstructedSegment;
    normRecomposed(idx:idx + l_v - 1) = normRecomposed(idx:idx + l_v - 1) + window;
end

recomposedFromPulse = recomposedFromPulse ./ (normRecomposed + eps);
recomposedFromPulse = recomposedFromPulse / max(abs(recomposedFromPulse) + eps);

if any(abs(recomposedFromPulse) > 0)
    audiowrite(fullfile(outputDir, sprintf('%s_recomposed_from_pulse.wav', audioBaseName)), recomposedFromPulse, fs);
end

figure;
plot((0:length(recomposedFromPulse)-1)/fs, recomposedFromPulse);
title('Señal recompuesta desde pulso modificado');
xlabel('Tiempo (s)');
ylabel('Amplitud');
grid on;

figure;
spectrogram(recomposedFromPulse, 256, 128, 512, fs, 'yaxis');
title('Espectrograma de la señal recompuesta desde pulso');

%% 7. MODIFICACIÓN EN DOMINIO DEL TIEMPO
fprintf('Modificando pitch en dominio del tiempo...\n');
signalModified = modifyPitch(signal, fs, isVoiced, pitchShift, selectionStartTime, selectionEndTime);

% 8. ANÁLISIS LPC DE LA SEÑAL MODIFICADA
%fprintf('Recomponiendo señal...\n');
%signalReconstructed = reconstructSignal(signalModified, fs, lpcCoeffs, lpcOrder, gain);

%% 8. VISUALIZACIÓN DE RESULTADOS
plotSignal(signalModified, fs, 'Señal Modificada');
%plotSignal(signalReconstructed, fs, 'Señal Reconstruida');

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
audiowrite(fullfile(outputDir, sprintf('%s_modified.wav', audioBaseName)), signalModified, fs);
%audiowrite(fullfile(outputDir, sprintf('%s_reconstructed.wav', audioBaseName)), signalReconstructed, fs);

fprintf('\n=== PROCESO COMPLETADO ===\n');
