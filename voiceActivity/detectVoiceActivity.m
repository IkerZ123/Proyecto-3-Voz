function [voiceActive, params] = detectVoiceActivity(signal, fs, varargin)
    % DETECTVOICEACTIVITY Detección de Actividad de Voz (VAD)
    %
    %   Sintaxis:
    %       [voiceActive, params] = detectVoiceActivity(signal, fs)
    %       [voiceActive, params] = detectVoiceActivity(signal, fs, frameDuration)
    %
    %   Entrada:
    %       signal (vector): Señal de audio
    %       fs (int): Frecuencia de muestreo (Hz)
    %       frameDuration (float, opcional): Duración de frames en segundos (default: 0.025)
    %
    %   Salida:
    %       voiceActive (vector): Binario indicando actividad de voz por frame
    %       params (struct): Parámetros utilizados
    %
    %   Descripción:
    %       Detecta presencia de voz usando energía y tasa de cruces por cero.
    
    % Parámetros por defecto
    if nargin > 2
        frameDuration = varargin{1};
    else
        frameDuration = 0.025;
    end
    
    frameSamples = round(frameDuration * fs);
    
    % Calcular energía y ZCR
    energy = computeEnergy(signal, frameSamples);
    zcr = computeZCR(signal, frameSamples);
    
    % TODO: Implementar lógica de detección
    % - Combinar energía y ZCR
    % - Aplicar umbral adaptativo
    % - Aplicar suavizado temporal
    
    % Placeholder: usar umbral simple en energía
    energyThreshold = 0.01 * max(energy);
    voiceActive = energy > energyThreshold;
    
    % Estructura de parámetros
    params.frameDuration = frameDuration;
    params.frameSamples = frameSamples;
    params.energyThreshold = energyThreshold;
    
end
