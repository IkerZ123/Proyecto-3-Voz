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
    %       usando autocorrelación para estimar F0.
    
    frameDuration = 0.025;
    frameSamples = round(frameDuration * fs);
    
    % Estimar F0 usando autocorrelación
    F0 = computeF0(signal, fs);
    
    % TODO: Implementar lógica de detección de sonoridad
    % - Usar autocorrelación
    % - Combinar con característica de energía ZCR
    % - Determinar umbral de confianza
    
    % Placeholder: considerar como sonoro si F0 > 50 Hz
    isVoiced = (F0 > 50) & voiceActive;
    confidence = ones(size(F0)) * 0.5; % Confianza placeholder
    
end
