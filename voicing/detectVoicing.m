function [isVoiced, F0, confidence] = detectVoicing(signal, fs, voiceActive)
    % DETECTVOICING Detección de Sonoridad
    %
    %   Sintaxis:
    %       [isVoiced, F0, confidence] = detectVoicing(signal, fs, voiceActive)
    %
    %   Entrada:
    %       signal (vector): Señal de audio
    %       fs (int): Frecuencia de muestreo (Hz)
    %       voiceActive (vector): Indicador de actividad de voz por frame
    %
    %   Salida:
    %       isVoiced (vector): Binario indicando sonoridad
    %       F0 (vector): Frecuencia fundamental (Hz)
    %       confidence (vector): Confianza de la estimación
    %
    %   Descripción:
    %       Detecta si cada frame es sonoro (voiced) o sordo (unvoiced)
    %       usando autocorrelación, energía y ZCR.
    
    frameDuration = 0.025;
    frameSamples = round(frameDuration * fs);
    
    % Estimar F0 y confianza de pico en autocorrelación
    [F0, f0Conf] = computeF0(signal, fs, frameDuration);
    
    % Calcular energía y ZCR del mismo framing
    energy = computeEnergy(signal, frameSamples);
    zcr = computeZCR(signal, frameSamples);
    energyDB = 10 * log10(energy + eps);

    % Umbrales adaptativos
    energyThresh = prctile(energyDB, 30);   % 30% congela ruido
    zcrThresh = 0.20;                       % Voz suele baja ZCR

    isEnergySpeech = energyDB >= energyThresh;
    isLowZCR = zcr <= zcrThresh;
    isF0Good = (F0 >= 60 & F0 <= 400);      % rango plausible vocal
    isConfGood = f0Conf >= 0.30;            % autocorrelación robusta

    % Detección combinada
    isVoiced = (voiceActive & isF0Good & isConfGood);

    % Si no hay detección por F0 pero todavía hay actividad, usar energía baja restricción
    lowEnergyReason = (voiceActive & isEnergySpeech);
    isVoiced = isVoiced | (lowEnergyReason & (f0Conf >= 0.20));

    % Suavizado temporal simple (hangover) para segmentos de voz reales
    isVoiced = medfilt1(double(isVoiced), 3) > 0.5;

    % Confianza combinada
    confidence = f0Conf;
    confidence(~isLowZCR) = confidence(~isLowZCR) * 0.8;
    confidence(~voiceActive) = confidence(~voiceActive) * 0.25;
    confidence(isVoiced) = min(confidence(isVoiced) + 0.25, 1);

end
