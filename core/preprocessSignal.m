function signal = preprocessSignal(signal)
    % PREPROCESSSIGNAL Preprocesamiento básico de la señal
    %
    %   Sintaxis:
    %       signal = preprocessSignal(signal)
    %
    %   Entrada:
    %       signal (vector): Señal de audio original
    %
    %   Salida:
    %       signal (vector): Señal preprocesada
    %
    %   Descripción:
    %       Aplica filtrado pasa-altos, normalización y otros
    %       preprocesamiento necesario antes del análisis.
    
    % TODO: Implementar preprocesamiento
    % - Aplicar filtro pasa-altos para remover ruido de baja frecuencia
    % - Normalizar la señal
    % - Aplicar preénfasis si es necesario
    
    % Por ahora, solo normalizar
    signal = signal / max(abs(signal));
    
end
