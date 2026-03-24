function signal = preprocessSignal(signal, fs, varargin)
    % PREPROCESSSIGNAL Preprocesamiento de la señal de audio
    %
    %   Sintaxis:
    %       signal = preprocessSignal(signal, fs)
    %       signal = preprocessSignal(signal, fs, 'HPF', cutoff)
    %
    %   Entrada:
    %       signal (vector): Señal de audio original
    %       fs (int): Frecuencia de muestreo (Hz)
    %       HPF (float, opcional): Frecuencia de corte pasa-altos en Hz (default: 50)
    %
    %   Salida:
    %       signal (vector): Señal preprocesada
    %
    %   Descripción:
    %       Aplica filtrado pasa-altos, preénfasis, normalización y 
    %       validación de entrada para preparar la señal al análisis.
    
    % Parámetros por defecto
    hpfCutoff = 50; % Hz - frecuencia de corte del filtro pasa-altos
    preemphasisCoeff = 0.97; % Coeficiente de preénfasis
    
    % Procesar argumentos opcionales
    for i = 1:2:length(varargin)
        if strcmp(varargin{i}, 'HPF')
            hpfCutoff = varargin{i+1};
        end
    end
    
    % 1. VALIDACIÓN DE ENTRADA
    if ~validateInput(signal, fs)
        error('Entrada inválida');
    end
    
    % 2. CONVERTIR A VECTOR COLUMNA
    signal = signal(:);
    
    % 3. NORMALIZACIÓN DE AMPLITUD (prevenir saturación en filtros)
    maxVal = max(abs(signal));
    if maxVal > 0
        signal = signal / maxVal;
    end
    
    % 4. FILTRO PASA-ALTOS
    % Remover DC (componente de 0 Hz) y ruido de baja frecuencia
    [b, a] = butter(4, hpfCutoff / (fs/2), 'high');
    signal = filter(b, a, signal);
    
    % 5. PREÉNFASIS
    % Realza las frecuencias altas para mejorar la calidad del análisis
    % s(n) = s(n) - alpha*s(n-1), típicamente alpha = 0.97
    signal = [signal(1); signal(2:end) - preemphasisCoeff * signal(1:end-1)];
    
    % 6. NORMALIZACIÓN FINAL
    % Escalar la señal a rango [-1, 1]
    maxVal = max(abs(signal));
    if maxVal > 0
        signal = signal / maxVal;
    end
    
    fprintf('  ✓ Filtro pasa-altos: %.1f Hz\n', hpfCutoff);
    fprintf('  ✓ Preénfasis: α = %.2f\n', preemphasisCoeff);
    
end
