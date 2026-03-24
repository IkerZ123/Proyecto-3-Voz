function tractvocal = extractTract(lpcCoeffs)
    % EXTRACTTRACT Extrae la respuesta del tracto vocal
    %
    %   Sintaxis:
    %       tractvocal = extractTract(lpcCoeffs)
    %
    %   Entrada:
    %       lpcCoeffs (matrix): Coeficientes LPC
    %
    %   Salida:
    %       tractvocal (matrix): Respuesta del tracto vocal
    %
    %   Descripción:
    %       Los coeficientes LPC representan el tracto vocal.
    %       Esta función prepara la respuesta para ser utilizada.
    
    tractvocal = lpcCoeffs;
    
end
