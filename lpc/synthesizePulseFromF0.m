function pulse = synthesizePulseFromF0(F0, isVoiced, fs, lenSignal, frameDuration)
% SYNTHESIZEPULSEFROMF0 Genera una excitación periódica a partir de F0
%
%   pulse = synthesizePulseFromF0(F0, isVoiced, fs, lenSignal, frameDuration)
%
%   F0         : vector de frecuencia fundamental por frame (Hz)
%   isVoiced   : indicador de sonoridad por frame
%   fs         : frecuencia de muestreo
%   lenSignal  : longitud de la señal de salida
%   frameDuration: duración de frame en segundos
%
%   pulse      : tren de impulsos sintetizado

if nargin < 5
    frameDuration = 0.025;
end

frameSamples = round(frameDuration * fs);
pulse = zeros(lenSignal, 1);
numFrames = min(length(F0), ceil(lenSignal / frameSamples));

for i = 1:numFrames
    idxStart = (i-1) * frameSamples + 1;
    idxEnd = min(idxStart + frameSamples - 1, lenSignal);
    if idxEnd < idxStart
        break;
    end
    if ~isVoiced(i) || F0(i) <= 0
        continue;
    end

    period = max(round(fs / F0(i)), 1);
    frameLength = idxEnd - idxStart + 1;
    framePulse = zeros(frameLength, 1);
    pulsePositions = 1:period:frameLength;
    framePulse(pulsePositions) = 1;
    envelope = hamming(frameLength);
    framePulse = framePulse .* envelope;
    pulse(idxStart:idxEnd) = pulse(idxStart:idxEnd) + framePulse;
end

pulse = pulse / max(abs(pulse) + eps);
end
