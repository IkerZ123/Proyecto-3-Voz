function acf = computeACF(frame, maxLag)
    % COMPUTEACF Calcula la Autocorrelación
    %
    %   Sintaxis:
    %       acf = computeACF(frame, maxLag)
    %
    %   Entrada:
    %       frame (vector): Frame de audio
    %       maxLag (int): Máximo lag a calcular
    %
    %   Salida:
    %       acf (vector): Autocorrelación normalizada
    %
    %   Descripción:
    %       Calcula la autocorrelación normalizada del frame.
    
    % Limitar maxLag al tamaño del frame
    maxLag = min(maxLag, length(frame));
    
    acf = xcorr(frame, maxLag, 'unbiased');
    acf = acf(maxLag+1:end); % Tomar solo lags positivos
    acf = acf / acf(1); % Normalizar
    
end
