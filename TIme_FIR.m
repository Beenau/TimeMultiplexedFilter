device = serial('COM5', 'BaudRate', 115200, 'Terminator', 'CR');
fclose(instrfind);

fopen(device);

%default floating point arrays
xn = [];
hn = [];

%Arrays to hold fixed point conversion
xnfi = [];
hnfi = [];

%floating point inputs and coefficients
xn = [1/5, -2/5, 3/5, -4/5];
hn = [-1/3, 4/5, 2/5];

%fixed point inputs and coefficients
xnfi = fi(xn', 1, 8, 6);
hnfi = fi(hn', 1, 8, 6);

%conver coeff and inputs to binary
x_bin = xnfi.bin;
h_bin = hnfi.bin;

x_as_char = [];
for k = 1 : 4
    for i = 1 : 8 : 8
        num_byte = bin2dec(x_bin(k,(i : i + 7)));
        x_as_char(1,end+1) = char(num_byte);
    end
end

%send x inputs
for i = 1 : length(x_as_char)
    if(i == length(x_as_char))
        fprintf(device, x_as_char(1, i));
    else
        fwrite(device, x_as_char(1, i), 'char');
    end
end

pause(1);


hex_digits = (fread(device, device.BytesAvailable, 'char'))';

value_recv_bin = '';

for i = 1 : length(hex_digits)
    current_digit_bin = dec2bin(hex2dec(hex_digits(1,i)), 4);
    if(i == 7||i == 8||i == 15||i == 16||i == 23||i == 24||i == 31||i == 32)
        value_recv_bin = [value_recv_bin current_digit_bin];
    end
end

cell_value = cellstr(reshape(value_recv_bin,8,[])');
%temp = cell2mat(cell_value);
%yFixedPoint = reinterpretcast(temp,numerictype(1,8,6));

y_fpga = [];
for i = 1 : 4
    y_fpga(i) = reinterpretcast(uint8(bin2dec(cell_value{i})),numerictype(1,8,6));
end

%END OF DEVICE COMMUNICATION

%compute the output y using floating point
yfloat = [];
for n = 1 : 4
    if(n == 1)
        yfloat(n) = hn(1)*xn(n);
    end
    if(n == 2)
        yfloat(n) = hn(1)*xn(n) + hn(2)*xn(n-1);
    end
    if(n >= 3)
    yfloat(n) = hn(1)*xn(n) + hn(2)*xn(n-1) + hn(3)*xn(n-2);
    end
end
%compute the output y array using fixed point
yfixed = [];
for n = 1 : 4
    if(n == 1)
        yfixed(n) = hnfi(1)*xnfi(n);
    end
    if(n == 2)
        yfixed(n) = hnfi(1)*xnfi(n) + hnfi(2)*xnfi(n-1);
    end
    if(n >= 3)
        yfixed(n) = hnfi(1)*xnfi(n) + hnfi(2)*xnfi(n-1) + hnfi(3)*xnfi(n-2);
    end
end


disp(yfloat)
disp(yfixed)
disp(y_fpga)

error_float = [];
error_fixed = [];
for i = 1 : 4
    error_float(i) = abs(yfloat(1,i)-y_fpga(1,i));
    error_fixed(i) = abs(yfixed(1,i)-y_fpga(1,i));
end

figure
subplot(5,1,1)
plot(yfloat, 'b')
title("Floating Point FIR")
xlabel('Sample Point', 'FontSize', 8);
ylabel('FIR Result', 'FontSize', 8);
subplot(5,1,2)
plot(yfixed, 'r')
title("Fixed Point FIR")
xlabel('Sample Point', 'FontSize', 8);
ylabel('FIR Result', 'FontSize', 8);
subplot(5,1,3)
plot(y_fpga, 'g')
title("FPGA FIR")
xlabel('Sample Point', 'FontSize', 8);
ylabel('FIR Result', 'FontSize', 8);
subplot(5,1,4)
stem(error_float)
title("Floating Point / FPGA Absolute Error")
xlabel('Sample Point', 'FontSize', 8);
ylabel('FIR Result', 'FontSize', 8);
subplot(5,1,5)
stem(error_fixed)
title("Fixed Point / FPGA Absolute Error")
xlabel('Sample Point', 'FontSize', 8);
ylabel('FIR Result', 'FontSize', 8);
