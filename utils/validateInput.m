function isValid = validateInput(signal, fs)
    % VALIDATEINPUT Valida que la entrada sea apropiada
    %
    %   Sintaxis:
    %       isValid = validateInput(signal, fs)
    %
    %   Entrada:
    %       signal (vector): Señal de audio
    %       fs (int): Frecuencia de muestreo
    %
    %   Salida:
    %       isValid (logical): true si la entrada es válida
    %
    %   Descripción:
    %       Verifica que la señal y frecuencia de muestreo sean válidas.
    
    isValid = true;
    
    % Verificar que signal sea un vector
    if ~isvector(signal)
        warning('La señal debe ser un vector');
        isValid = false;
    end
    
    % Verificar que fs sea positivo
    if fs <= 0
        warning('La frecuencia de muestreo debe ser positiva');
        isValid = false;
    end
    
    % Verificar que signal no esté vacío
    if isempty(signal)
        warning('La señal no puede estar vacía');
        isValid = false;
    end
    
end
