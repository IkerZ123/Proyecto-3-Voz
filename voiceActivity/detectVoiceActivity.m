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

    % Convertir energía a dB (evitar -inf)
    energyDB = 10 * log10(energy + eps);

    % Normalizar energía a [0,1] para umbral fijo
    energyMin = min(energyDB);
    energyMax = max(energyDB);
    if energyMax > energyMin
        energyNorm = (energyDB - energyMin) / (energyMax - energyMin);
    else
        energyNorm = zeros(size(energyDB));
    end

    % Umbral fijo para energía normalizada (acorde a voz típica)
    energyThreshold = 0.1;  % 10% del rango dinámico
    energyHigh = 0.3;       % 30% para voz fuerte

    % Umbral de ZCR para voz (voz tiene ZCR bajo, pero permitimos mayor rango de vocales)
    zcrThreshold = 0.30;

    % Detección inicial: energía + zcr
    isHighEnergy = energyNorm >= energyHigh;
    isSpeechEnergy = energyNorm >= energyThreshold;
    isLowZCR = zcr <= zcrThreshold;

    voiceActive = (isSpeechEnergy & isLowZCR) | isHighEnergy;

    % Si el análisis de energía es pobre, permitir voz basada solo en energía alta
    if sum(voiceActive) < 5
        voiceActive = energyNorm >= 0.15;  % umbral mínimo
    end

    % Post-procesado / suavizado: eliminar burst cortos y llenar gaps cortos
    minVoiceFrames = max(2, round(0.03 / frameDuration));      % 30 ms mínimos
    maxGapFrames = max(1, round(0.05 / frameDuration));        % 50 ms para rellenar gaps
    hangoverFrames = max(1, round(0.1 / frameDuration));       % 100 ms hangover

    % Rellenar gaps cortos (hangover para pausas dentro de voz)
    gapCount = 0;
    for i = 1:length(voiceActive)
        if voiceActive(i)
            gapCount = 0;
        else
            gapCount = gapCount + 1;
            if gapCount <= maxGapFrames
                voiceActive(i) = true;
            end
        end
    end

    % Hangover: mantener voz activa por hangoverFrames después de detección
    hangoverCount = 0;
    for i = 1:length(voiceActive)
        if voiceActive(i)
            hangoverCount = hangoverFrames;  % reset hangover
        elseif hangoverCount > 0
            voiceActive(i) = true;
            hangoverCount = hangoverCount - 1;
        end
    end

    % Eliminar segmentos menor a minVoiceFrames
    i = 1;
    while i <= length(voiceActive)
        if voiceActive(i)
            j = find(~voiceActive(i:end), 1, 'first');
            if isempty(j)
                j = length(voiceActive) - i + 1;
            end
            segmentLength = j;
            if segmentLength < minVoiceFrames
                voiceActive(i:i+segmentLength-1) = false;
            end
            i = i + segmentLength;
        else
            i = i + 1;
        end
    end

    % Lijar con filtro de mediana (núcleo 3 para estabilidad)
    voiceActive = medfilt1(double(voiceActive), 3) > 0.5;

    % Retornar parámetros adicionales
    params.frameDuration = frameDuration;
    params.frameSamples = frameSamples;
    params.energyDB = energyDB;
    params.energyNorm = energyNorm;
    params.zcr = zcr;
    params.energyThreshold = energyThreshold;
    params.energyHigh = energyHigh;
    params.zcrThreshold = zcrThreshold;
    params.minVoiceFrames = minVoiceFrames;
    params.maxGapFrames = maxGapFrames;
    params.hangoverFrames = hangoverFrames;

end
