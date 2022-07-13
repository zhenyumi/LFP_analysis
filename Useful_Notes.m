%% Ask for help
help < function name > % Open website help
doc < function name > % Open help in command line
edit < function name > % Open .m file

%% Operation for variables
which < name > % Determine a variable_name is used or not

%% Functions
% Print
disp()

%% Code
% Enumerate
for i = 1:length(foo_list)
    item = foo_list(i);
    % do stuff with i, item
end
% Connect a string
['a' 'b' 'c'] → 'abc'
["a" "b" "c"] → a string array
strcat('a', "b", 'c'); → 'abc'

%% Structure
% Set var default value in a function
function f = name(var_name)
   if(~exist('var_name','var'))
        var_name = dafault_value;
   end
end