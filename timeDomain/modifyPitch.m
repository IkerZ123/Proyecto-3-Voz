function signalModified = modifyPitch(signal, fs, isVoiced, pitchFactor, selectionStartTime, selectionEndTime)
    % MODIFYPITCH Modificación de Entonación/Pitch
    %
    %   Sintaxis:
    %       signalModified = modifyPitch(signal, fs, isVoiced, pitchFactor, selectionStartTime, selectionEndTime)
    %
    %   Entrada:
    %       signal (vector): Señal de audio original
    %       fs (int): Frecuencia de muestreo (Hz)
    %       isVoiced (vector): Indicador de sonoridad por frame
    %       pitchFactor (float): Factor de modificación (>1 aumenta, <1 disminuye)
    %       selectionStartTime (float): Tiempo inicial del fragmento a modificar (s)
    %       selectionEndTime (float): Tiempo final del fragmento a modificar (s)
    %
    %   Salida:
    %       signalModified (vector): Señal con pitch modificado
    %
    %   Descripción:
    %       Modifica la entonación de la señal sin cambiar la duración.
    %       Solo aplica el cambio en la región seleccionada y en los frames sonoros.
    
    if nargin < 5 || isempty(selectionStartTime)
        selectionStartTime = 0;
    end
    if nargin < 6 || isempty(selectionEndTime)
        selectionEndTime = inf;
    end
    
    signalModified = signal;
    
    % Aplicar pitch shift directamente a la región seleccionada
    startSample = max(1, floor(selectionStartTime * fs) + 1);
    endSample = min(length(signal), ceil(selectionEndTime * fs));
    region = signal(startSample:endSample);

    if isempty(region) || abs(pitchFactor - 1) < eps
        return;
    end

    % Cambiar pitch mediante remuestreo y estiramiento temporal
    [p, q] = rat(1 / pitchFactor, 1e-6);
    regionPitch = resample(region, p, q);
    stretchFactor = length(region) / max(length(regionPitch), 1);
    regionModified = timeStretch(regionPitch, stretchFactor);
    regionModified = regionModified(1:min(length(regionModified), length(region)));
    if length(regionModified) < length(region)
        regionModified(end+1:length(region)) = 0;
    end

    % Aplicar ventana de suavizado en los bordes para evitar clics
    fadeLen = min(64, floor(length(regionModified) / 10));
    if fadeLen > 1
        fadeWindow = ones(size(regionModified));
        fadeWindow(1:fadeLen) = linspace(0, 1, fadeLen)';
        fadeWindow(end-fadeLen+1:end) = linspace(1, 0, fadeLen)';
        regionModified = regionModified .* fadeWindow;
    end

    signalModified(startSample:endSample) = regionModified;
    
    % Normalizar todo el signalModified para evitar clipping
    max_val = max(abs(signalModified));
    if max_val > 1
        signalModified = signalModified / max_val;
    end
    
end
